using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AnimationInstancingTest : MonoBehaviour
{
    public Transform root;
    public GameObject prefab;
    public GameObject prefab2;
    // Start is called before the first frame update
    AnimationClip[] clips ;

    GameObject[] objList = new GameObject[500];
    void Start()
    {;
        // Animator animator = prefab.GetComponentInChildren<Animator>(true);
        // clips = animator.runtimeAnimatorController.animationClips;
        for(int i = 0;i<500;i++) {
            GameObject obj = Instantiate(prefab,GetRandomPos(true),Quaternion.identity);
            obj.name = prefab.name;
            obj.transform.SetParent(root,true);
            objList[i] = obj;

            // obj.GetComponentInChildren<Animator>().enabled = true;
            // obj.GetComponentInChildren<Animator>().Play(clips[Random.Range(0,clips.Length)].name);
        }
        // for(int i = 0;i<500;i++) {

        //     GameObject obj2 = Instantiate(prefab2,GetRandomPos(false),Quaternion.identity);
        //     obj2.transform.SetParent(root,true);
        //     // obj.GetComponentInChildren<Animator>().enabled = true;
        //     // obj.GetComponentInChildren<Animator>().Play(clips[Random.Range(0,clips.Length)].name);
        // }
    }

    Vector3 GetRandomPos(bool left) {
        if(left) {
            return new Vector3(Random.Range(-14,14),0,Random.Range(-8,8));
        }
        else {
            return new Vector3(Random.Range(2,14),0,Random.Range(-8,8));
        }
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
