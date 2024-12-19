using UnityEngine;

namespace wc.framework
{
    public class DontDestroy : MonoBehaviour
    {
        private void Awake() {
            DontDestroyOnLoad(this);
        }
    }
}
