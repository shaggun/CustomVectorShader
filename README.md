# CustomVectorShader
More functionality to vector graphics shader for Unity
=====================================
![gif](https://i.imgur.com/WGWJsCf.gif)

This is a custom shader based on the unlit gradient shader included in the Vector Graphics Preview Package.

I wanted to use the same shader for SVG with gradients and with solid colors so I combined both shaders, now you can use the color property of the Sprite Renderer component to change the vector color even the ones with gradients.

I noticed that when I added the UnitySprites.cginc file I broke the flip functionality so I fixed it by using transform values instead, I also needed to skew the vectors so now you can skew along axis X and Y(obviously)

I'm using MaterialPropertyBlock to makes the changes, make sure you enable GPU instancing when you create your own materials, I didn't want to use an Update function to update the changes for a couple of properties, I wanted to take advantage of the property setter but as you know you cannot expose properties in Unity, only public fields, fortunately I stumbled upon an awesome asset called [Property Backing Field Drawer] it's free and it lets you expose properties as fields, you can find more info about it [here]. 

**Requirements:** 
1. Add [Property Backing Field Drawer] asset once you download the project if you want to reuse my script with exposed properties, otherwise you will get errors, if you only want to use the shader then it's not necessary.

2. Download the latest Vector Graphics package with the Package Manager**

**Tested with Unity 2018.2.0f2**

[Property Backing Field Drawer]:https://assetstore.unity.com/packages/tools/utilities/property-backing-field-drawer-18253

[here]:http://adammechtley.com/2014/06/property-backing-field-drawer/


