/***************
Shaders adapted for SceneBuilder from these fine gents:
https://github.com/keilmillerjr/shader-module
https://github.com/Luke-Nukem/attract-extra/tree/master/layouts/shaders
**************/

local BASE_PATH = FeConfigDirectory + "modules/scenebuilder/"

class SceneBuilderShader {
    name = null;
    props = null;
    shader = null;
    constructor(name, shader, props = {}) {
        this.props = props;
        this.shader = shader;
    }
}

SceneBuilder.shader("crt-lottes", function(props = {}) {
        SceneBuilder.print_debug(
            "\n" +
            "crt-lottes available shader params:\n" +
            " width: def=640\n" +
            "   texture width\n" +
            " height: def=480\n" +
            "   texture height\n" +
            " aperature: def=2.0\n" +
            "   0 = VGA style shadow mask\n" +
            "   1.0 = Very compressed TV style shadow mask.\n" +
            "   2.0 = Aperture-grille.\n" +
            " blackclip: def=0.08\n" +
            "   drops the final color value by this amount if GAMMA_CONTRAST_BOOST is defined\n" +
            " brightmult: def=1.25\n" +
            "   multiplies the color settings by this amount if GAMMA_CONTRAST_BOOST is defined\n" +
            " cornersize: def=0.038\n" +
            " cornersmooth: def=400.0\n" +
            "   accepts values 100-1000\n" +
            " curvature: def=0\n" +
            "   0 = Flat\n" +
            "   1.0 = Curved\n" +
            " distortion: def=0.1\n" +
            " hardpix: def=-2.3\n" +
            "   -2.0 = soft\n" +
            "   -4.0 = hard\n" +
            " hardscan: def=-10.0\n" +
            "   -8.0 = soft\n" +
            "   -16.0 = medium\n" +
            " maskdark: def=0.4\n" +
            " masklight: def=1.3\n" +
            " rotated: def=1.0\n" +
            "   0 = Scan line orientation vertical\n" +
            "   1 = Scan line orientation horizontal\n" +
            " saturation: def=1.25\n" +
            "   1.0 is normal saturation, increase as needed\n" +
            " tint: def=0.1\n" +
            "   0.0 is 0.0 degrees of tint. adjust as needed\n"
        );

        props = SceneBuilder.merge_props({
            width = 640,
            height = 480,
            curvature = 0,
            aperature = 2.0,
            distortion = 0.1,
            cornersize = 0.038,
            cornersmooth = 400.0,
            hardscan = -10.0,
            hardpix = -2.3,
            maskdark = 0.4,
            masklight = 1.3,
            saturation = 1.25,
            tint = 0.1,
            blackclip = 0.08,
            brightmult = 1.25,
            rotated = 1.0
        }, props);

        local shader = ::fe.add_shader(Shader.VertexAndFragment, BASE_PATH + "shaders/crt-lottes.vert", BASE_PATH + "shaders/crt-lottes.frag");
        shader.set_param("blackClip", props.blackclip);
        shader.set_param("curvature", props.curvature);
        shader.set_param("aperature_type", props.aperature);
        shader.set_param("distortion", props.distortion);
        shader.set_param("cornersize", props.cornersize);
        shader.set_param("cornersmooth", props.cornersmooth);
        shader.set_param("hardScan", props.hardscan);
        shader.set_param("hardPix", props.hardpix);
        shader.set_param("maskDark", props.maskdark);
        shader.set_param("maskLight", props.masklight);
        shader.set_param("brightMult", props.brightmult);
        shader.set_param("saturation", props.saturation);
        shader.set_param("tint", props.tint);
        shader.set_param("rotated", props.rotated);
        shader.set_param("color_texture_sz", props.width, props.height);
		shader.set_param("color_texture_pow2_sz", props.width, props.height);
		shader.set_texture_param("mpass_texture");

        return SceneBuilderShader("crt-lottes", shader, props);
});

SceneBuilder.shader("rounded-corners", function(props = {}) {
        SceneBuilder.print_debug(
            "\n" +
            "rounded-corners available shader params:\n" +
            " width: def=640\n" +
            "   texture width\n" +
            " height: def=480\n" +
            "   texture height\n" +
            " subimg_width: def=640\n" +
            "   subimg width\n" +
            " subimg_height: def=480\n" +
            "   subimg height\n" +
            " radius: 15\n" +
            "   corner radius\n"
        );

        props = SceneBuilder.merge_props({
            width = 640,
            height = 480,
            subimg_width = null,
            subimg_height = null,
            radius = 15,
        }, props);
        if ( props.subimg_width == null ) props.subimg_width = props.width;
        if ( props.subimg_height == null ) props.subimg_height = props.height;
        
        local shader = ::fe.add_shader(Shader.Fragment, BASE_PATH + "shaders/rounded-corners.frag");
        shader.set_param("snap_dimensions", props.width, props.height);
        shader.set_param("subimg_dimensions", props.subimg_width, props.subimg_height);
        shader.set_param("radius", props.radius);

        return SceneBuilderShader("rounded-corners", shader, props);
});

SceneBuilder.shader("pixelate", function(props) {
    SceneBuilder.print_debug(
        "\n" +
        "pixelate available shader params:\n" +
        " width: def=640\n" +
        "   texture width\n" +
        " height: def=480\n" +
        "   texture height\n" +
        " pixel_w: def=8\n" +
        "   pixel width\n" +
        " pixel_h: def=8\n" +
        "   pixel height\n"
    );
    props = SceneBuilder.merge_props({
        width = 640,
        height = 480,
        pixel_w = 8,
        pixel_h = 8
    }, props);
    local shader = ::fe.add_shader(Shader.Fragment, BASE_PATH + "shaders/pixelate.frag");
    shader.set_param("rt_w", props.width);
    shader.set_param("rt_h", props.height);
    shader.set_param("pixel_w", props.pixel_w);
    shader.set_param("pixel_h", props.pixel_h);
    return SceneBuilderShader("pixelate", shader, props);
})