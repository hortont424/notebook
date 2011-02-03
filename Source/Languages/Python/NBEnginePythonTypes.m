/*
 * Copyright 2011 Tim Horton. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 * this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY TIM HORTON "AS IS" AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
 * SHALL TIM HORTON OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,
 * EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include "NBEnginePythonTypes.h"

id _PyObject_AsNSObject(PyObject * obj, NSMapTable * seen)
{
    id seenObject = NSMapGet(seen, obj);

    if(seenObject)
    {
        return [NSString stringWithFormat:@"<recursion: %p>", seenObject];
    }
    else if(PyString_Check(obj))
    {
        return [NSString stringWithUTF8String:PyString_AsString(obj)];
    }
    else if(PyUnicode_Check(obj))
    {
        return [NSString stringWithUTF8String:PyString_AsString(obj)];
    }
    else if(PyInt_Check(obj))
    {
        return [NSNumber numberWithLong:PyInt_AsLong(obj)];
    }
    else if(PyFloat_Check(obj))
    {
        return [NSNumber numberWithDouble:PyFloat_AsDouble(obj)];
    }
    else if(PyLong_Check(obj))
    {
        return [NSNumber numberWithLongLong:PyLong_AsLongLong(obj)];
    }
    else if(PyList_Check(obj))
    {
        Py_ssize_t listCount = PyList_Size(obj);
        NSMutableArray * list = [[NSMutableArray alloc] initWithCapacity:listCount];

        NSMapInsert(seen, obj, list);

        for(Py_ssize_t currentItem = 0; currentItem < listCount; currentItem++)
        {
            [list addObject:_PyObject_AsNSObject(PyList_GetItem(obj, currentItem), [seen copy])];
        }

        return list;
    }
    else if(PyDict_Check(obj))
    {
        NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];

        NSMapInsert(seen, obj, dict);

        PyObject * key, * value;
        Py_ssize_t pos = 0;

        while(PyDict_Next(obj, &pos, &key, &value))
        {
            [dict setObject:_PyObject_AsNSObject(value, [seen copy]) forKey:_PyObject_AsNSObject(key, [seen copy])];
        }

        return dict;
    }
    else if(PyTuple_Check(obj))
    {
        Py_ssize_t tupleCount = PyTuple_Size(obj);
        NSMutableArray * tuple = [[NSMutableArray alloc] initWithCapacity:tupleCount];

        NSMapInsert(seen, obj, tuple);

        for(Py_ssize_t currentItem = 0; currentItem < tupleCount; currentItem++)
        {
            [tuple addObject:_PyObject_AsNSObject(PyTuple_GetItem(obj, currentItem), [seen copy])];
        }

        return tuple;
    }
    else
    {
        NSLog(@"unknown type with object %p!!", obj);
        return _PyObject_AsNSObject(PyObject_Str(obj), [seen copy]);
    }

    return nil;
}

id PyObject_AsNSObject(PyObject * obj)
{
    NSMapTable * seen = NSCreateMapTable(NSNonOwnedPointerOrNullMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 100);
    return _PyObject_AsNSObject(obj, seen);
}

NSString * PyObject_NSObjectClassName(PyObject * obj)
{
    Class objcClass = nil;

    if(PyString_Check(obj) || PyUnicode_Check(obj))
    {
        objcClass = [NSString class];
    }
    else if(PyInt_Check(obj) || PyFloat_Check(obj) || PyLong_Check(obj))
    {
        objcClass = [NSNumber class];
    }
    else if(PyList_Check(obj))
    {
        objcClass = [NSArray class];
    }
    else if(PyDict_Check(obj))
    {
        objcClass = [NSDictionary class];
    }
    else if(PyTuple_Check(obj))
    {
        objcClass = [NSArray class];
    }
    else
    {
        NSLog(@"unknown type with object %p!!", obj);
    }

    return NSStringFromClass(objcClass);
}
