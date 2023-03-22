Clamp :: (value: float, min: float, max: float) -> float
{
    res := ifx value < min then min else value;
    return ifx res > max then max else res;
}

Lerp :: (start: float, end: float, amount: float) -> float
{
    return start + amount*(end - start);
}

Normalize :: (value: float, start: float, end: float) -> float
{
    return (value - start)/(end - start);
}

Remap :: (value: float, inputStart: float, inputEnd: float, outputStart: float, outputEnd: float) -> float
{
    return (value - inputStart)/(inputEnd - inputStart)*(outputEnd - outputStart) + outputStart;
}

Vector2Zero :: () -> Vector2
{
    return .{ 0, 0 };
}

Vector2One :: () -> Vector2
{
    return .{ 1, 1 };
}

Vector2Add :: (v1: Vector2, v2: Vector2) -> Vector2
{
    return make_vector2(v1.x + v2.x, v1.y + v2.y);
}

Vector2AddValue :: (v: Vector2, add: float) -> Vector2
{
    return make_vector2(v.x + add, v.y + add);
}

Vector2Subtract :: (v1: Vector2, v2: Vector2) -> Vector2
{
    return make_vector2(v1.x - v2.x, v1.y - v2.y);
}

Vector2SubtractValue :: (v: Vector2, sub: float) -> Vector2
{
    return make_vector2(v.x - sub, v.y - sub);
}

Vector2Length :: (v: Vector2) -> float
{
    return sqrt((v.x*v.x) + (v.y*v.y));
}

Vector2Scale :: (v: Vector2, scale: float) -> Vector2
{
    return make_vector2(v.x*scale, v.y*scale);
}

Vector2Scale :: (a: Vector2, b: Vector2) -> Vector2 {
    return make_vector2(a.x * b.x, a.y * b.y);
}

Vector2Normalize :: (v: Vector2) -> Vector2 {
    return Vector2Scale(v, 1/Vector2Length(v));
}

#scope_file
#import "Math";
