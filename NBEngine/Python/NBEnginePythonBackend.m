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

#import "NBEnginePythonBackend.h"

@implementation NBEnginePythonBackend

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


- (NBException *)retrievePythonException
{
    NBException * err;
    
    PyObject * exceptionType, * exceptionValue, * exceptionTraceback;
    PyObject * exceptionOffset, * exceptionLine;
    
    if(!PyErr_Occurred())
    {
        return nil;
    }
    
    err = [[NBException alloc] init];
    
    PyErr_Fetch(&exceptionType, &exceptionValue, &exceptionTraceback);
    PyErr_NormalizeException(&exceptionType, &exceptionValue, &exceptionTraceback);
    
    exceptionOffset = PyObject_GetAttrString(exceptionValue, "offset");
    exceptionLine = PyObject_GetAttrString(exceptionValue, "lineno");
    
    if(exceptionOffset)
    {    
        err.column = PyInt_AsLong(exceptionOffset);
    }
    
    if(exceptionLine)
    {
        err.line = PyInt_AsLong(exceptionLine);
    }
    
    err.message = [NSString stringWithUTF8String:PyString_AsString(PyObject_Str(exceptionValue))];
    
    PyErr_Clear();
    
    return err;
}

- (PyObject *)capturePythonStdout
{
    // Install a StringIO object as sys.stdout so we can intercept Python's output
    // TODO: intercept stderr too!
    
    PyObject * stringIOModule = PyImport_Import(PyString_FromString("StringIO"));
    PyObject * stringIOConstructor = PyObject_GetAttrString(stringIOModule, "StringIO");
    PyObject * stringIOObject = PyObject_Call(stringIOConstructor, PyTuple_New(0), NULL);
    
    PySys_SetObject("stdout", stringIOObject);
    
    return stringIOObject;
}

- (NSString *)prepareCapturedPythonStdout:(PyObject *)stringIOObject
{
    // Retrieve the final value of the StringIO object we installed as sys.stdout
    
    PyObject * stringIOGetValueFunction = PyObject_GetAttrString(stringIOObject, "getvalue");
    PyObject * stdoutValue = PyObject_Call(stringIOGetValueFunction, PyTuple_New(0), NULL);
    NSString * stdoutString = [NSString stringWithUTF8String:PyString_AsString(stdoutValue)];
    
    // If the output string ends in a newline, strip it out (TODO: is this the right thing to do?)
    
    if([stdoutString length] && ([stdoutString characterAtIndex:[stdoutString length] - 1] == '\n'))
        stdoutString = [stdoutString substringToIndex:[stdoutString length] - 1];
    
    return stdoutString;
}

- (oneway void)executeSnippet:(NSString *)snippet
{
    PyObject * pythonStdout, * compiledSnippet;
    
    // Try to compile the given snippet of Python
    
    compiledSnippet = Py_CompileString([snippet UTF8String], "snippet", Py_file_input);
    
    if(!compiledSnippet)
    {
        // Compilation failed, bail out and inform the caller (attempting to retrieve the compilation error on the way)
        
        [engine snippetComplete:[self retrievePythonException] withOutput:nil];
        return;
    }
    
    // Capture stdout
    
    pythonStdout = [self capturePythonStdout];
    
    // Execute the code in the context of our engine
    
    PyEval_EvalCode((PyCodeObject *)compiledSnippet, globals, globals); // TODO: check about sending globals as locals
    
    // Let the caller know that we're done, including any exceptions that occurred and any captured output
    
    [engine snippetComplete:[self retrievePythonException] withOutput:[self prepareCapturedPythonStdout:pythonStdout]];
}

@end
