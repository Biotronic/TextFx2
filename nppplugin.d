module nppplugin;

import core.sys.windows.dll;
import win32.windows;
import plugininterface;
import scintilla;
import notepad_plus_msgs;
import util;
import std.exception;

alias toStringz = std.string.toStringz;
alias toStringz = util.toStringz;

abstract class NppPlugin {
    @property
    HWND currentHandle() {
        int which = -1;
        SendMessage(nppData._nppHandle, NPPM_GETCURRENTSCINTILLA, 0, cast(LPARAM)&which);
        return which ? nppData._scintillaSecondHandle : nppData._scintillaMainHandle;
    }

    @property
    string text() {
        int length = SendMessage(currentHandle, SCI_GETLENGTH, 0, 0);
        auto result = new char[length+1];
        SendMessage(currentHandle, SCI_GETTEXT, length+1, cast(LPARAM)result.ptr);
        return result[0..$-1].assumeUnique;
    }

    @property
    string text(string value) {
        SendMessage(currentHandle, SCI_SETTEXT, value.length, cast(LPARAM)value.toStringz);
        return value;
    }

    @property
    string selectedText() {
        int length = SendMessage(currentHandle, SCI_GETSELTEXT, 0, 0);
        auto result = new char[length+1];
        SendMessage(currentHandle, SCI_GETSELTEXT, length+1, cast(LPARAM)result.ptr);
        return result[0..$-2].assumeUnique;
    }

    @property
    string selectedText(string value) {
        SendMessage(currentHandle, SCI_REPLACESEL, value.length, cast(LPARAM)value.toStringz);
        return value;
    }
    
    @property
    string activeText() {
        int length = SendMessage(currentHandle, SCI_GETSELTEXT, 0, 0)-1;
        if (length) {
            return selectedText;
        } else {
            return text;
        }
    }
    
    @property
    string activeText(string value) {
        int length = SendMessage(currentHandle, SCI_GETSELTEXT, 0, 0)-1;
        if (length) {
            return selectedText = value;
        } else {
            return text = value;
        }
    }
    
    void alert(T)(T text) {
        MessageBox(nppData._nppHandle, to!string(text).toStringz, "Message".toStringz, 0);
    }
    
    void commandMenuInit() {}
private:
    HINSTANCE instance;
    NppData nppData;
    FuncItem[] functions;
}

public __gshared NppPlugin plugin;


extern(C):

export void setInfo(NppData notepadPlusData) {
    plugin.nppData = notepadPlusData;
    plugin.commandMenuInit();
}

export const(wchar)* getName() {
    return "&TextFx2"w.toStringz;
}

export FuncItem* getFuncsArray(int* numfunctions) {
    *numfunctions = plugin.functions.length;
    return &plugin.functions[0];
}

export void beNotified(SCNotification*) {
    
}

export LRESULT messageProc(UINT Message, WPARAM wParam, LPARAM lParam) {
    return 0;
}

export BOOL isUnicode() {
    return true;
}

extern (Windows) BOOL DllMain(HINSTANCE hInstance, ULONG ulReason, LPVOID pvReserved) {
    switch (ulReason) {
    case DLL_PROCESS_ATTACH:
        plugin.instance = hInstance;
        dll_process_attach( cast(void*)hInstance, true );
        break;
    case DLL_PROCESS_DETACH:
        dll_process_detach( cast(void*)hInstance, true );
        break;
    case DLL_THREAD_ATTACH:
        dll_thread_attach( true, true );
        break;
    case DLL_THREAD_DETACH:
        dll_thread_detach( true, true );
        break;
    default:
        break;
    }
    
    return true;
}