// colorEffect・distortionEffect・layerEffect の見本で使うシェーダー（ShaderLibrary.default から呼ぶ）
#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

// colorEffect: width の幅ごとの横縞で、1 本おきに暗くする
[[ stitchable ]] half4 stripes(float2 position, half4 color, float width) {
    bool dark = fmod(floor(position.y / width), 2.0) == 1.0;
    return dark ? half4(color.rgb * 0.4h, color.a) : color;
}

// colorEffect: 明るさが level より上なら白、下なら黒にする
[[ stitchable ]] half4 threshold(float2 position, half4 color, float level) {
    half luminance = dot(color.rgb, half3(0.299h, 0.587h, 0.114h));
    half value = luminance > half(level) * color.a ? color.a : 0.0h;
    return half4(value, value, value, color.a);
}

// distortionEffect: 横に進む波で、縦にずらした場所の色を取る
[[ stitchable ]] float2 wave(float2 position, float amplitude, float wavelength) {
    return float2(position.x, position.y + amplitude * sin(position.x / wavelength * 2.0 * M_PI_F));
}

// layerEffect: size の升ごとに、升の中央の色で塗る
[[ stitchable ]] half4 pixelate(float2 position, SwiftUI::Layer layer, float size) {
    float2 cell = (floor(position / size) + 0.5) * size;
    return layer.sample(cell);
}
