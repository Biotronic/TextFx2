//this file is part of notepad++
//Copyright (C)2003 Don HO <donho@altern.org>
//
//This program is free software; you can redistribute it and/or
//modify it under the terms of the GNU General Public License
//as published by the Free Software Foundation; either
//version 2 of the License, or (at your option) any later version.
//
//This program is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with this program; if not, write to the Free Software
//Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

module plugininterface;

import win32.windows;
import scintilla;
import notepad_plus_msgs;

enum nbChar = 64;

alias extern(C) const(wchar)* function() PFUNCGETNAME;
alias extern(C) void function(NppData) PFUNCSETINFO;
alias extern(C) void function() PFUNCPLUGINCMD;
alias extern(C) void function(SCNotification*) PBENOTIFIED;
alias extern(C) LRESULT function(UINT Message, WPARAM wParam, LPARAM lParam) PMESSAGEPROC;

struct NppData {
	HWND _nppHandle;
	HWND _scintillaMainHandle;
	HWND _scintillaSecondHandle;
}

struct ShortcutKey {
	bool _isCtrl;
	bool _isAlt;
	bool _isShift;
	UCHAR _key;
}

struct FuncItem {
	wchar[nbChar] _itemName;
	PFUNCPLUGINCMD _pFunc;
	int _cmdID;
	bool _init2Check;
	ShortcutKey *_pShKey;
}

alias extern(C) FuncItem* function(int*)PFUNCGETFUNCSARRAY;

// You should implement (or define an empty function body) those functions which are called by Notepad++ plugin manager
extern(C) {
    export void setInfo(NppData);
    export const(wchar)* getName();
    export FuncItem* getFuncsArray(int*);
    export void beNotified(SCNotification*);
    export LRESULT messageProc(UINT Message, WPARAM wParam, LPARAM lParam);
    export BOOL isUnicode();
}