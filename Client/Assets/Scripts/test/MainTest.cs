using System.Collections;
using System.Collections.Generic;
using UnityEngine;

using wc.framework;
public class MainTest : MonoBehaviour
{
    // Start is called before the first frame update
    IEnumerator Start()
    {
        ManifestManager.Instance.InitManifest();
        yield return null;
    }

    // Update is called once per frame

}
