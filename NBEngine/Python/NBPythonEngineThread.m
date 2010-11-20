/*
 * Copyright 2010 Tim Horton. All rights reserved.
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

#import "NBPythonEngineThread.h"

@implementation NBPythonEngineThread

@synthesize connection;

+ (void)connectWithPorts:(NSArray *)ports
{
    NSAutoreleasePool * pool;
    NSConnection * classConnection;
    NBPythonEngineThread * engine;
    
    pool = [[NSAutoreleasePool alloc] init];
    classConnection = [NSConnection connectionWithReceivePort:[ports objectAtIndex:0] sendPort:[ports objectAtIndex:1]];
    engine = [[self alloc] init];
    
    engine.connection = classConnection;
    
    [((NBPythonEngine *)[classConnection rootProxy]) setEngine:engine];
    
    [[NSRunLoop currentRunLoop] run];
    
    [pool drain];
}

- (id)init
{
    self = [super init];
    
    if (self != nil)
    {
        Py_Initialize();
        
        mainModule = PyImport_AddModule("__main__");
        globals = PyModule_GetDict(mainModule);
    }
    
    return self;
}


- (NBException *)parsePythonException
{
    NBException * err = [[NBException alloc] init];
    
    PyObject * exceptionType, * exceptionValue, * exceptionTraceback;
    PyObject * exceptionOffset, * exceptionLine, * exceptionMessage;
    
    PyErr_Fetch(&exceptionType, &exceptionValue, &exceptionTraceback);
    PyErr_NormalizeException(&exceptionType, &exceptionValue, &exceptionTraceback);
    
    exceptionOffset = PyObject_GetAttrString(exceptionValue, "offset");
    exceptionLine = PyObject_GetAttrString(exceptionValue, "lineno");
    exceptionMessage = PyObject_GetAttrString(exceptionValue, "msg");
    
    if(exceptionOffset)
    {    
        err.column = PyInt_AsLong(exceptionOffset);
    }
    
    if(exceptionLine)
    {
        err.line = PyInt_AsLong(exceptionLine);
    }
    
    if(exceptionMessage)
    {
        err.message = [NSString stringWithUTF8String:PyString_AsString(exceptionMessage)];
    }
    else
    {
        exceptionMessage = PyObject_GetAttrString(exceptionValue, "message");
        
        if(exceptionMessage)
        {
            err.message = [NSString stringWithUTF8String:PyString_AsString(exceptionMessage)];
        }
    }
    
    return err;
}

- (oneway void)executeSnippet:(NSString *)snippet
{
    PyObject * codeObject = Py_CompileString([snippet UTF8String], "snippet", Py_file_input);
    
    if(!codeObject && PyErr_Occurred())
    {
        NBException * err = [self parsePythonException];
        PyErr_Clear();
        
        [((NBPythonEngine *)[connection rootProxy]) snippetComplete:err];
        
        return;
    }
    
    PyEval_EvalCode((PyCodeObject *)codeObject, globals, globals);
    
    if(PyErr_Occurred())
    {
        NBException * err = [self parsePythonException];
        PyErr_Clear();
        
        [((NBPythonEngine *)[connection rootProxy]) snippetComplete:err];
        
        return;
    }
    
    [((NBPythonEngine *)[connection rootProxy]) snippetComplete:nil];
}

@end
