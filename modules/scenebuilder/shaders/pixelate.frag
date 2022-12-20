//http://www.geeks3d.com/20101029/shader-library-pixelation-post-processing-effect-glsl/
uniform sampler2D texture;
uniform float rt_w;
uniform float rt_h;
uniform float pixel_w;
uniform float pixel_h;

void main()
{   
    vec2 uv = gl_TexCoord[0].xy;

    vec3 tc = vec3(1.0, 0.0, 0.0);
    float dx = pixel_w*(1./rt_w);
    float dy = pixel_h*(1./rt_h);
    vec2 coord = vec2(dx*floor(uv.x/dx),
                      dy*floor(uv.y/dy));
    tc = texture2D(texture, coord).rgb;
    gl_FragColor = vec4(tc, 1.0);
}