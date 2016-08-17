from entity import *


class Section(Entity):
    _columns = ['title']
    _parents = []
    _children = {'categories': 'Category'}
    _siblings = {}


class Category(Entity):
    _columns = ['title']
    _parents = ['section']
    _children = {'posts': 'Post'}
    _siblings = {}


class Post(Entity):
    _columns = ['content', 'title']
    _parents = ['category']
    _children = {'comments': 'Comment'}
    _siblings = {'tags': 'Tag'}


class Comment(Entity):
    _columns = ['text']
    _parents = ['post', 'user']
    _children = {}
    _siblings = {}


class Tag(Entity):
    _columns = ['name']
    _parents = []
    _children = {}
    _siblings = {'posts': 'Post'}


class User(Entity):
    _columns = ['name', 'email', 'age']
    _parents = []
    _children = {'comments': 'Comment'}
    _siblings = {}


if __name__ == "__main__":
    Entity.db = psycopg2.connect(
        database="testdb", user="postgres", password="shmel", host="127.0.0.1", port="5432")


    section = Section(6)
    category = Category(10)
    post = Post(2)
    # post.content = 'fucking awesome content_4'
    # post.category = 9
    # post.save()
    # print post.tags
    # for tag in post.tags:
    #     print tag.name
    # tag = Tag()
    # tag.name = "OXYENNI TAG_3"
    # tag.save()
    # section.title = "MEGAzalupa"

    # result =[]

    # for category in section.categories:
    #     result.append(category.title)
    # print result
    # category.title = "GOPA"
    # category.section = 6
    # print category.section.title
    # print category.title
    # print category.id
    # category.save()
    # print category.__dict__
    # print Section().__class__.__dict__
    # section.title = "zalupiCHESKAIAsila"
    # print section.title
    # section.save()
    # print section.title
    # print section.id
    # print section.created
    # print section.updated
    
    # section.title = "superzalupa"
    # section.save()
    # print section.__class__.__dict__
    # print section.__dict__
    # print section.title



    # print section.id
    # print section.created
    # print section.updated

    # print section.id
    # print section.created
    # print section.updated

    # section2 = Section()
    # section2.title = "zalupa na vorotnike"
    # section2.save()
    # print section2.title

    # for cate in Section.all():
    #     print cate.title

    section._Entity__cursor.close()
    Entity.db.close()
