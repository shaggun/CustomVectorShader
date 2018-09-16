using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(SpriteRenderer))]
public class VectorExtended : MonoBehaviour {

    private Renderer _renderer;
    private MaterialPropertyBlock _propBlock;
    [SerializeField, Candlelight.PropertyBackingField]
    private float _XSkew;
    [SerializeField, Candlelight.PropertyBackingField]
    private float _YSkew;
    [SerializeField, Candlelight.PropertyBackingField]
    private bool _FlipVectorX;
    [SerializeField, Candlelight.PropertyBackingField]
    private bool _FlipVectorY;

    // Use this for initialization
    private void Awake()
    {
        _propBlock = new MaterialPropertyBlock();
        _renderer = GetComponent<Renderer>();
    }

    void Start()
    {
        // Get the current value of the material properties in the renderer.
        _renderer.GetPropertyBlock(_propBlock);
        _renderer.SetPropertyBlock(_propBlock);

    }

    public bool FlipVectorY
    {
        get { return _FlipVectorY; }
        set { _FlipVectorY = value;
            if (_FlipVectorY)
            {
                //180 degrees around X
                transform.rotation = Quaternion.Euler(180, transform.rotation.y, transform.rotation.z);

            }
            else
            {
                //0 degrees around X
                transform.rotation = Quaternion.Euler(0, transform.rotation.y, transform.rotation.z);
                
                
            }
        }
    }

    public bool FlipVectorX
    {
        get { return _FlipVectorX; }
        set { _FlipVectorX = value;
            if (_FlipVectorX)
            {
                //180 degrees around Y
                transform.rotation = Quaternion.Euler(transform.rotation.x, 180, transform.rotation.z);
            }
            else
            {
                //0 degrees around Y
                transform.rotation = Quaternion.Euler(transform.rotation.x, 0, transform.rotation.z);
            }

        }
    }

    public float XSkew
    {
        get { return _XSkew; }
        set
        {   _XSkew = value;
            _propBlock.SetFloat("_HorizontalSkew", _XSkew);
            _renderer.SetPropertyBlock(_propBlock);
        }
    }

    public float YSkew
    {
        get { return _YSkew; }
        set
        {
            _YSkew = value;
            _propBlock.SetFloat("_VerticalSkew", _YSkew);
            _renderer.SetPropertyBlock(_propBlock);
        }
    }

}
