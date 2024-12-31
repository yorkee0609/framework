using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
namespace wc.framework
{
    public class NormalButton:OnGuiInterface{
        public delegate void OnButtonClicked(NormalButton button);
        public event OnButtonClicked OnClick;
        private string _text;
        public int _index
        {
            get;
            private set;
        }
        private float _width;
        private bool _selected;
        public NormalButton(string text, int index ,float width = 100)
        {
            _text = text;
            _index = index;
            _width = width;
            _selected = false;
        }

        public void OnGUI()
        {
            Color preColor = GUI.color;
            if(_selected) {
                GUI.color = Color.green;
            }
            else {
                GUI.color = Color.white;
            }
            if(GUILayout.Button(_text,GUILayout.Width(_width))) {
                OnClick?.Invoke(this);
                _selected = true;
            }
            GUI.color = preColor;
        }

        public void ClearSelected() {
            _selected = false;
        }
    }
}