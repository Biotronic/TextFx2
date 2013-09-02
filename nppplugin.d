module nppplugin;

import win32.windows;
import plugininterface;
import scintilla;
import notepad_plus_msgs;
import std.exception;
import util;
import std.string;

abstract class NppPlugin {
    @property
    HWND currentHandle() {
        int which = -1;
        SendMessage(nppData._nppHandle, NPPM_GETCURRENTSCINTILLA, 0, cast(LPARAM)&which);
        return which ? nppData._scintillaSecondHandle : nppData._scintillaMainHandle;
    }

    @property
    string text() {
        int length = sendMessage(SCI_GETLENGTH, 0, 0);
        auto result = new char[length+1];
        sendMessage(SCI_GETTEXT, length+1, cast(LPARAM)result.ptr);
        return result[0..$-1].assumeUnique;
    }

    @property
    string text(string value) {
        sendMessage(SCI_SETTEXT, value.length, cast(LPARAM)value.toStringz);
        return value;
    }

    @property
    string selectedText() {
        int length = sendMessage(SCI_GETSELTEXT);
        auto result = new char[length+1];
        sendMessage(SCI_GETSELTEXT, length+1, cast(LPARAM)result.ptr);
        return result[0..$-2].assumeUnique;
    }

    @property
    string selectedText(string value) {
        sendMessage(SCI_REPLACESEL, value.length, cast(LPARAM)value.toStringz);
        return value;
    }
    
    @property
    string activeText() {
        int length = sendMessage(SCI_GETSELTEXT)-1;
        if (length) {
            return selectedText;
        } else {
            return text;
        }
    }
    
    @property
    string activeText(string value) {
        int length = sendMessage(SCI_GETSELTEXT)-1;
        if (length) {
            return selectedText = value;
        } else {
            return text = value;
        }
    }
	
	@property
	int caretPos() {
		return sendMessage(SCI_GETCURRENTPOS);
	}
	
	@property
	int caretPos(int value) {
		sendMessage(SCI_SETCURRENTPOS, value);
		return value;
	}
	
	@property
	int anchorPos() {
		return sendMessage(SCI_GETANCHOR);
	}
	
	@property
	int anchorPos(int value) {
		sendMessage(SCI_SETANCHOR, value);
		return value;
	}
	
	int sendMessage(int msg, int a = 0, int b = 0) {
		return SendMessage(currentHandle, msg, a, b);
	}
    
    void alert(T)(T text) {
        MessageBox(nppData._nppHandle, to!string(text).toStringz, "Message".toStringz, 0);
    }

	void commandMenuInit() {}
	
    NppData nppData;
    FuncItem[] functions;
}