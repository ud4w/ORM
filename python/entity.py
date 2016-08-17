import psycopg2.extras
import sys


class DatabaseError(Exception):
    pass


class NotFoundError(Exception):
    pass


class Entity(object):
    db = None

    # ORM part 1
    __delete_query = 'DELETE FROM "{table}" WHERE {table}_id=%s'
    __insert_query = 'INSERT INTO "{table}" ({columns}) VALUES ({placeholders}) RETURNING "{table}_id"'
    __list_query = 'SELECT * FROM "{table}"'
    __select_query = 'SELECT * FROM "{table}" WHERE {table}_id=%s'
    __update_query = 'UPDATE "{table}" SET {columns} WHERE {table}_id=%s'

    # ORM part 2
    __parent_query = 'SELECT * FROM "{table}" WHERE {parent}_id=%s'
    __sibling_query = 'SELECT * FROM "{sibling}" NATURAL JOIN "{join_table}" WHERE {table}_id=%s'
    __update_children = 'UPDATE "{table}" SET {parent}_id=%s WHERE {table}_id IN ({children})'

    def __init__(self, id=None):
        if self.__class__.db is None:
            raise DatabaseError()

        self.__cursor = self.__class__.db.cursor(
            cursor_factory=psycopg2.extras.DictCursor
        )
        self.__fields = {}
        self.__id = id
        self.__loaded = False
        self.__modified = False
        self.__table = self.__class__.__name__.lower()

    def __getattr__(self, name):
        print "trying to get %s" % (name)
        if self.__modified:
            raise DatabaseError()
        if self.__loaded is False and self.id is not None:
            self.__load()
        if name in self._columns:
            return self._get_column(name)
        if name in self._parents:
            return self._get_parent(name)
        if name in self._children:
            return self._get_children(name)
        if name in self._siblings:
            return self._get_siblings(name)

        raise NotFoundError()
        # check, if instance is modified and throw an exception
        # get corresponding data from database if needed
        # check, if requested property name is in current class
        #    columns, parents, children or siblings and call corresponding
        #    getter with name as an argument
        # throw an exception, if attribute is unrecognized

    def __setattr__(self, name, value):
        print "trying to set-up %s with %s" % (name, value)
        if name in self._columns:
            self._set_column(name, value)
        if name in self._parents:
            self._set_parent(name, value)
            return
        super(Entity, self).__setattr__(name, value)
        # check, if requested property name is in current class
        #    columns, parents, children or siblings and call corresponding
        # setter with name and value as arguments or use default implementation

    def __execute_query(self, query, args=None):
        try:
            self.__cursor.execute(query, args)
            self.db.commit()
        except psycopg2.Warning as warning:
            sys.stdout.write(warning)
        except psycopg2.Error as err:
            self.db.rollback()
            sys.stderr.write(err.pgerror + ' with code ' + err.pgcode)
        # execute an sql statement and handle exceptions together with
        # transactions

    def __insert(self):
        columns = []
        placeholders = []
        args = []

        for key, val in self.__fields.iteritems():
            columns.append(key)
            placeholders.append('%s')
            args.append(val)

        columns = ', '.join(columns)
        placeholders = ', '.join(placeholders)

        query = self.__insert_query.format(
            table=self.__table, columns=columns, placeholders=placeholders)

        self.__execute_query(query, args)
        self.__id = self.__cursor.fetchone()[0]

        # generate an insert query string from fields keys and values and execute it
        # use prepared statements
        # save an insert id

    def __load(self):
        query = self.__select_query.format(table=self.__table)
        args = (self.id, )

        self.__execute_query(query, args)
        self.__fields = {col : val for col, val in self.__cursor.fetchone().iteritems()}
        self.__loaded = True
        # if current instance is not loaded yet - execute select statement and
        # store it's result as an associative array (fields), where column
        # names used as keys

    def __update(self):
        columns = []
        args = (self.id, )

        for key, val in self.__fields.iteritems():
            column_value = key + " = '" + val + "'"
            columns.append(column_value)
        columns = ', '.join(columns)

        query = self.__update_query.format(
            table=self.__table, columns=columns)

        self.__execute_query(query, args)
        # generate an update query string from fields keys and values and execute it
        # use prepared statements

    def _get_children(self, name):
        module = __import__('models')
        children_class = getattr(module, self._children[name])
        instances = []

        children = self._children[name].lower()
        query = self.__parent_query.format(table=children, parent=self.__table)
        args = (self.id, )

        self.__execute_query(query, args)

        for row in self.__cursor.fetchall():
            instance = children_class()
            instance.__fields = {col : val for col, val in row.iteritems()}
            instance.__loaded = True
            instances.append(instance)

        return instances
        # return instances
        # return an array of child entity instances
        # each child instance must have an id and be filled with data

    def _get_column(self, name):
        column = [self.__table, name]
        column = '_'.join(column)

        return self.__fields[column]
        # return value from fields array by <table>_<name> as a key

    def _get_parent(self, name):
        if isinstance(self.__fields[name + '_id'], name.title()):
            return self.__fields[name + '_id']
        module = __import__('models')
        parent_class = getattr(module, name.title())
        instance = parent_class(self.__fields[name + '_id'])
        return instance
        # ORM part 2
        # get parent id from fields with <name>_id as a key
        # return an instance of parent entity class with an appropriate id

    def _get_siblings(self, name):
        module = __import__('models')
        sibling_class = getattr(module, self._siblings[name])

        instances = []
        sibling = self._siblings[name].lower()
        table = self.__table
        if len(table) > len(sibling):
            join_table = table + '__' + sibling
        else:
            join_table = sibling + '__' + table

        query = self.__sibling_query.format(sibling=sibling, join_table=join_table, table=table)
        args = (self.id, )

        self.__execute_query(query, args)

        for row in self.__cursor.fetchall():
            instance = sibling_class()
            instance.__fields = {col : val for col, val in row.iteritems()}
            instance.__loaded = True
            instances.append(instance)

        return instances
        # ORM part 2
        # get parent id from fields with <name>_id as a key
        # return an array of sibling entity instances
        # each sibling instance must have an id and be filled with data

    def _set_column(self, name, value):
        column = [self.__table, name]
        column = '_'.join(column)
        self.__fields[column] = value
        self.__modified = True
        # put new value into fields array with <table>_<name> as a key

    def _set_parent(self, name, value):
        parent= name + '_id'
        self.__fields[parent] = value
        # ORM part 2
        # put new value into fields array with <name>_id as a key
        # value can be a number or an instance of Entity subclass

    @classmethod
    def all(cls):
        query = cls.__list_query.format(table=cls.__name__.lower())
        instances = []

        instance = cls()
        instance.__execute_query(query)
        cursor_dict = instance.__cursor.fetchall()
        del instance

        for row in cursor_dict:
            instance = cls()
            instance.__fields = {col : val for col, val in row.iteritems()}
            instance.__loaded = True
            instances.append(instance)

        return instances
        # get ALL rows with ALL columns from corrensponding table
        # for each row create an instance of appropriate class
        # each instance must be filled with column data, a correct id and MUST NOT query a database for own fields any more
        # return an array of istances

    def delete(self):
        query = self.__delete_query.format(table=self.__table)
        args = (self.id, )

        self.__execute_query(query, args)
        # execute delete query with appropriate id

    @property
    def id(self):
        return self.__id
        # try to guess yourself

    @property
    def created(self):
        return next(v for  k, v in self.__fields.iteritems() if k.endswith('created'))
        # try to guess yourself

    @property
    def updated(self):
        return next(v for  k, v in self.__fields.iteritems() if k.endswith('updated'))
        # try to guess yourself

    def save(self):
        if self.id is not None:
            self.__update()
            self.__modified = False
            self.__loaded = False
        else:
            self.__insert()
            self.__modified = False
        # execute either insert or update query, depending on instance id
