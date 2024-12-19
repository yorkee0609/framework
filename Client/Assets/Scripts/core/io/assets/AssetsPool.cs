using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Assertions;

namespace wc.framework
{
    public class AssetPool 
    {
        private string assetName;
        private GameObject template;
        private Queue<GameObject> pool = new Queue<GameObject>();
        private List<GameObject> activePool = new List<GameObject>();

        public AssetPool(string assetName,GameObject template)
        {
            this.assetName = assetName;
            this.template = template;
        
        }

        public GameObject Get()
        {
            GameObject obj = null;
            if (pool.Count > 0)
            {
                obj = pool.Dequeue();
            }
            else
            {
                obj =  GameObject.Instantiate(template);
                obj.name = assetName;
            }
            activePool.Add(obj);
            return obj;
        }

        public void Return(GameObject obj)
        {
            activePool.Remove(obj);
            pool.Enqueue(obj);
            obj.transform.SetParent(AssetsManager.Instance.poolRoot);
        }

        public void Clear()
        {
            // clear后return的active obj自己销毁
            // Assert.IsTrue(activePool.Count == 0);
            // foreach (var item in activePool)
            // {
            //     GameObject.Destroy(item);
            // }
            foreach (var item in pool)
            {
                GameObject.Destroy(item);
            }
            pool.Clear();
            activePool.Clear();
        }
    }
}