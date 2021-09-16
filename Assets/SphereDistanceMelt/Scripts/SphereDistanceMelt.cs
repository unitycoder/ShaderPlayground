using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SphereDistanceMelt : MonoBehaviour
{
    public Transform sphere;
    public Renderer targetRenderer;

    void Update()
    {
        // send sphere position to shader
        targetRenderer.sharedMaterial.SetVector("_pos", sphere.position);
    }
}
