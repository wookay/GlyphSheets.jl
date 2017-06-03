# FreeType DSL

module DSL

macro ok(block...)
    :(ret = $(esc(block...)); 0 == ret ? nothing : error($(esc(block))[1]))
end

export create_library, create_typeface, create_glyph, outline_decompose
export close_library, close_typeface
export pt, px

using FreeType
#=
function FT_Outline_Decompose(outline::FT_Outline,outline_funcs::FT_Outline_Funcs,user)
    ccall((:FT_Outline_Decompose,freetype),FT_Error,(Ptr{FT_Outline},Ptr{FT_Outline_Funcs},Ptr{Void}),pointer_from_objref(outline),pointer_from_objref(outline_funcs),user)
end
=#
 
struct Library
    ref::Ref{FT_Library}
end

struct TypeFace
    ref::Ref{FT_Face}
end

abstract type PathOperation end
struct Move <: PathOperation
    to
end

struct Line <: PathOperation
    to
end

struct Conic <: PathOperation
    control
    to
end

struct Cubic <: PathOperation
    control1
    control2
    to
end

function create_library()::Library
    reflibrary = Ref{FreeType.FT_Library}()
    @ok FT_Init_FreeType(reflibrary)
    Library(reflibrary)
end

function close_typeface(face::TypeFace)
    FT_Done_Face(face.ref[])
end

function close_library(library::Library)
    FT_Done_FreeType(library.ref[])
end

function create_typeface(library::Library, pathname::String)::TypeFace
    refface = Ref{FreeType.FT_Face}()
    @ok FT_New_Face(library.ref[], pathname, 0, refface)
    TypeFace(refface)
end

abstract type LengthUnit end
abstract type RelativeUnit <: LengthUnit end
abstract type AbsoluteUnit <: LengthUnit end

struct Point <: AbsoluteUnit
    val::Real
end

struct Pixel <: RelativeUnit
    val::Real
end

struct Glyph
    slot::FreeType.FT_GlyphSlotRec
    char::Char
    unit::LengthUnit
end

const pt = Point
const px = Pixel

Base.:*(n::Real, unit::Type{T}) where T <: LengthUnit = T(n)

Base.promote_rule(::Type{Pixel}, ::Type{Point}) = Point
Base.convert(::Type{Pixel}, pt::Point) = Pixel(4/3 * pt.val)
Base.convert(::Type{Point}, px::Pixel) = Pixel(3/4 * px.val)

function create_glyph(typeface::TypeFace, char::Char, unit::T) where T <: LengthUnit
    glyph_index = FT_Get_Char_Index(typeface.ref[], char)
    if isa(unit, RelativeUnit)
        pixel_width = pixel_height = UInt32(unit.val)
        @ok FT_Set_Pixel_Sizes(typeface.ref[], pixel_width, pixel_height)
    elseif isa(unit, AbsoluteUnit)
        char_width = char_height = 64unit.val
        horz_resolution = vert_resolution = 72
        @ok FT_Set_Char_Size(typeface.ref[], char_width, char_height, horz_resolution, vert_resolution)
    end
    @ok FT_Load_Glyph(typeface.ref[], glyph_index, FT_LOAD_DEFAULT)
    face = unsafe_load(typeface.ref[])
    slot = unsafe_load(face.glyph)
    Glyph(slot, char, unit)
end

function outline_decompose(glyph::Glyph)
    function pos(p::Ptr{FreeType.FT_Vector})
        vec = unsafe_load(p)
        (vec.x, vec.y)
    end

    move_f = cfunction(Cint,(Ptr{FreeType.FT_Vector},Ptr{Void})) do to, user_f
        C_NULL != user_f && ccall(user_f, Void, (Any,), Move(pos.([to])...))
        Cint(0)
    end
    
    line_f = cfunction(Cint,(Ptr{FreeType.FT_Vector},Ptr{Void})) do to, user_f
        C_NULL != user_f && ccall(user_f, Void, (Any,), Line(pos.([to])...))
        Cint(0)
    end
    
    conic_f = cfunction(Cint,(Ptr{FreeType.FT_Vector},Ptr{FreeType.FT_Vector},Ptr{Void})) do control, to, user_f
        C_NULL != user_f && ccall(user_f, Void, (Any,), Conic(pos.([control, to])...))
        Cint(0)
    end
    
    cubic_f = cfunction(Cint,(Ptr{FreeType.FT_Vector},Ptr{FreeType.FT_Vector},Ptr{FreeType.FT_Vector},Ptr{Void})) do control1, control2, to, user_f
        C_NULL != user_f && ccall(user_f, Void, (Any,), Cubic(pos.([control1, control2, to])...))
        Cint(0)
    end

    global paths = Vector()
    user_f = cfunction(Void, (PathOperation,)) do op
        push!(paths, op)
        nothing
    end

    outline_funcs = FreeType.FT_Outline_Funcs(move_f, line_f, conic_f, cubic_f, 0, 0)
    @ok FT_Outline_Decompose(glyph.slot.outline, outline_funcs, user_f)
    paths
end

end
