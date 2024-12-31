using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace wc.framework
{
    public class SearchBar:OnGuiInterface{

        public delegate void OnSearchBarChanged(string str);
        private string _searchText = "";
        private float _width;
        private bool _hasClear;
        public event OnSearchBarChanged OnSearchBarChangedInvoke;

        public SearchBar(float width = 200, bool hasClear = true)
        {
            _searchText = "";
            _width = width;
            _hasClear = hasClear;
        }
        public void OnGUI()
        {
            using (new EditorGUILayout.HorizontalScope())
            {
                string searchText = EditorGUILayout.TextField(_searchText,EditorStyles.toolbarSearchField,GUILayout.Width(_width));
                if(searchText != _searchText) {
                    _searchText = searchText;
                    OnSearchBarChangedInvoke?.Invoke(_searchText);
                }
                if(_hasClear) {
                    if(GUILayout.Button(EditorGUIUtility.IconContent("winbtn_mac_close_h"),EditorStyles.toolbarButton,GUILayout.Width(20))) {
                        if(!string.IsNullOrEmpty(_searchText))
                        {
                            _searchText = "";
                            OnSearchBarChangedInvoke?.Invoke(_searchText);
                            GUI.changed = true;
                            GUIUtility.keyboardControl = 0;
                        }
                    }
                }
            }

        }

        public string GetSearchText() {
            return _searchText;
        }
    }
}
