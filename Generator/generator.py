import yaml
import pprint


MANY2MANY = """CREATE TABLE "{table1}__{table2}" (
    "{table1}_id" INTEGER NOT NULL,
    "{table2}_id" INTEGER NOT NULL,
    PRIMARY KEY ("{table1}_id", "{table2}_id")
);

"""

CONSTRAINT_MANY2MANY = """ALTER TABLE "{table1}__{table2}"
    ADD CONSTRAINT "fk_{table1}__{table2}_{table1}_id" FOREIGN KEY ("{table1}_id") REFERENCES "{table1}" ("{table1}_id");

ALTER TABLE "{table1}__{table2}"
    ADD CONSTRAINT "fk_{table1}__{table2}_{table2}_id" FOREIGN KEY ("{table2}_id") REFERENCES "{table2}" ("{table2}_id");

"""

CONSTRAINT_ONE2MANY = """ALTER TABLE "{table1}" ADD "{table2}_id" INTEGER NOT NULL,
    ADD CONSTRAINT "fk_{table1}_{table2}_id" FOREIGN KEY ("{table2}_id") REFERENCES "{table2}" ("{table2}_id");

"""

TABLE = 'CREATE TABLE "{table}" (\n    "{table}_id" SERIAL PRIMARY KEY,\n'

FIELDS = '    "{table}_{col_name}" {col_type},\n'

STAMPS = """    "{table}_created" INTEGER NOT NULL DEFAULT cast(extract(epoch from now()) AS INTEGER),
    "{table}_updated" INTEGER NOT NULL DEFAULT cast(extract(epoch from now()) AS INTEGER)
);

"""
FUNCTION = """CREATE OR REPLACE FUNCTION update_{table}_timestamp()
RETURNS TRIGGER AS $$
BEGIN
   NEW.{table}_updated = cast(extract(epoch from now()) as integer);
   RETURN NEW;
END;
$$ language 'plpgsq';
"""
TRIGGER = 'CREATE TRIGGER tr_{table}_updated BEFORE UPDATE ON "{table}" FOR EACH ROW EXECUTE PROCEDURE update_{table}_timestamp();\n\n'


class ValidationError(Exception):
    def __init__(self, error, message="relations logic error in "):
        message += error
        super(ValidationError, self).__init__(message)


class Generator(object):

    def __init__(self):
        self.psql_statements = []

    def get_relations_and_validate(self, schema):
        many2many = {}
        one2many = {}
        for table, relations in schema.iteritems():
            if table in relations['relations']:
                raise ValidationError(error=table)

            for rel_table, relation in relations['relations'].iteritems():

                if table not in schema[rel_table]['relations']:
                    raise ValidationError(error=table)

                if relation == 'many' and schema[rel_table]['relations'][table] == 'many':
                    if len(rel_table) > len(table):
                        many2many[rel_table] = table
                    else:
                        many2many[table] = rel_table
                if relation == 'many' and schema[rel_table]['relations'][table] == 'one':
                        one2many[rel_table] = table

        return many2many, one2many

    def generate_many2many_table(self, statement, many2many):
        for key in many2many:
            statement.append(
                MANY2MANY.format(table1=key.lower(), table2=many2many[key].lower()))

    def generate_many2many_constraint(self, statement, many2many):
        for key in many2many:
            statement.append(
                CONSTRAINT_MANY2MANY.format(table1=key.lower(), table2=many2many[key].lower()))

    def generate_one2many_constraint(self, statement, one2many):
        for key in one2many:
            statement.append(
                CONSTRAINT_ONE2MANY.format(table1=key.lower(), table2=one2many[key].lower()))

    def generate_table(self, statement, schema):
        for table, fields in schema.iteritems():
            table = table.lower()
            statement.append(TABLE.format(table=table))
            for col_name, col_type in fields['fields'].iteritems():
                statement.append(FIELDS.format(table=table, col_name=col_name, col_type=col_type))
            statement.append(STAMPS.format(table=table))

    def generate_function_trigger(self, statement, schema):
        for table, fields in schema.iteritems():
            table = table.lower()
            statement.append(FUNCTION.format(table=table))
            statement.append(TRIGGER.format(table=table))

    def generate(self, source_file):
        with open(source_file, "r") as source:
            schema = yaml.load(source.read())

            statments = []
            many2many, one2many = self.get_relations_and_validate(schema)
            self.generate_many2many_table(statments, many2many)
            self.generate_table(statments, schema)
            self.generate_many2many_constraint(statments, many2many)
            self.generate_one2many_constraint(statments, one2many)
            self.generate_function_trigger(statments, schema)
        return statments



if __name__ == "__main__":
    gen = Generator()
    # gen.generate("schema.yaml")
    with open("schema.sql", "a+") as f:
        for stmnt in gen.generate("schema.yaml"):
            f.write(stmnt)

#     for table, fields in schema.iteritems():
#         table = table.lower()

#         create_function_trigger_statement = []
#         create_table_statement = []
#         create_table_statement.append(
#             TABLE.format(table=table))
#         for field in fields.itervalues():
#             for col_name, col_type in field.iteritems():
#                 create_table_statement.append(FIELDS.format(
#                     table=table, col_name=col_name, col_type=col_type))
#             create_table_statement.append(
#                 STAMPS.format(table=table))
#             create_function_trigger_statement.append(
#                 FUNCTION.format(table=table))
#             create_function_trigger_statement.append(
#                 TRIGGER.format(table=table))
#         self.psql_statements.append(''.join(create_table_statement))
#         self.psql_statements.append(
#             ''.join(create_function_trigger_statement))
# return self.psql_statements
