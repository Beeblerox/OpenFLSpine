/******************************************************************************
 * Spine Runtimes Software License v2.5
 *
 * Copyright (c) 2013-2016, Esoteric Software
 * All rights reserved.
 *
 * You are granted a perpetual, non-exclusive, non-sublicensable, and
 * non-transferable license to use, install, execute, and perform the Spine
 * Runtimes software and derivative works solely for personal or internal
 * use. Without the written permission of Esoteric Software (see Section 2 of
 * the Spine Software License Agreement), you may not (a) modify, translate,
 * adapt, or develop new applications using the Spine Runtimes or otherwise
 * create derivative works or improvements of the Spine Runtimes or (b) remove,
 * delete, alter, or obscure any trademarks or any copyright, trademark, patent,
 * or other intellectual property or proprietary rights notices on or in the
 * Software, including any copy thereof. Redistributions in binary or source
 * form must include this license and terms.
 *
 * THIS SOFTWARE IS PROVIDED BY ESOTERIC SOFTWARE "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO
 * EVENT SHALL ESOTERIC SOFTWARE BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES, BUSINESS INTERRUPTION, OR LOSS OF
 * USE, DATA, OR PROFITS) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER
 * IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 *****************************************************************************/

package spine.attachments;

import spine.support.graphics.Color;
import spine.support.graphics.TextureAtlas.AtlasRegion;
import spine.support.graphics.TextureRegion;
import spine.Animation.DeformTimeline;

/** An attachment that displays a textured mesh. A mesh has hull vertices and internal vertices within the hull. Holes are not
 * supported. Each vertex has UVs (texture coordinates) and triangles are used to map an image on to the mesh.
 * <p>
 * See <a href="http://esotericsoftware.com/spine-meshes">Mesh attachments</a> in the Spine User Guide. */
class MeshAttachment extends VertexAttachment {
    private var region:TextureRegion;
    private var path:String;
    private var regionUVs:FloatArray; private var uvs:FloatArray = null;
    private var triangles:ShortArray;
    private var color:Color = new Color(1, 1, 1, 1);
    private var hullLength:Int = 0;
    private var parentMesh:MeshAttachment;
    private var inheritDeform:Bool = false;

    // Nonessential.
    private var edges:ShortArray;
    private var width:Float = 0; private var height:Float = 0;

    public function new(name:String) {
        super(name);
    }

    #if !spine_no_inline inline #end public function setRegion(region:TextureRegion):Void {
        if (region == null) throw new IllegalArgumentException("region cannot be null.");
        this.region = region;
    }

    #if !spine_no_inline inline #end public function getRegion():TextureRegion {
        if (region == null) throw new IllegalStateException("Region has not been set: " + this);
        return region;
    }

    /** Calculates {@link #uvs} using {@link #regionUVs} and the {@link #region}. Must be called after changing the region UVs or
     * region. */
    #if !spine_no_inline inline #end public function updateUVs():Void {
        var u:Float = 0; var v:Float = 0; var width:Float = 0; var height:Float = 0;
        if (region == null) {
            u = v = 0;
            width = height = 1;
        } else {
            u = region.getU();
            v = region.getV();
            width = region.getU2() - u;
            height = region.getV2() - v;
        }
        var regionUVs:FloatArray = this.regionUVs;
        if (this.uvs == null || this.uvs.length != regionUVs.length) this.uvs = FloatArray.create(regionUVs.length);
        var uvs:FloatArray = this.uvs;
        if (Std.is(region, AtlasRegion) && (cast(region, AtlasRegion)).rotate) {
            var i:Int = 0; var n:Int = uvs.length; while (i < n) {
                uvs[i] = u + regionUVs[i + 1] * width;
                uvs[i + 1] = v + height - regionUVs[i] * height;
            i += 2; }
        } else {
            var i:Int = 0; var n:Int = uvs.length; while (i < n) {
                uvs[i] = u + regionUVs[i] * width;
                uvs[i + 1] = v + regionUVs[i + 1] * height;
            i += 2; }
        }
    }

    /** Returns true if the <code>sourceAttachment</code> is this mesh, else returns true if {@link #inheritDeform} is true and the
     * the <code>sourceAttachment</code> is the {@link #parentMesh}. */
    override public function applyDeform(sourceAttachment:VertexAttachment):Bool {
        return this == sourceAttachment || (inheritDeform && parentMesh == sourceAttachment);
    }

    /** Triplets of vertex indices which describe the mesh's triangulation. */
    #if !spine_no_inline inline #end public function getTriangles():ShortArray {
        return triangles;
    }

    #if !spine_no_inline inline #end public function setTriangles(triangles:ShortArray):Void {
        this.triangles = triangles;
    }

    /** The UV pair for each vertex, normalized within the texture region. */
    #if !spine_no_inline inline #end public function getRegionUVs():FloatArray {
        return regionUVs;
    }

    /** Sets the texture coordinates for the region. The values are u,v pairs for each vertex. */
    #if !spine_no_inline inline #end public function setRegionUVs(regionUVs:FloatArray):Void {
        this.regionUVs = regionUVs;
    }

    /** The UV pair for each vertex, normalized within the entire texture.
     * <p>
     * See {@link #updateUVs}. */
    #if !spine_no_inline inline #end public function getUVs():FloatArray {
        return uvs;
    }

    #if !spine_no_inline inline #end public function setUVs(uvs:FloatArray):Void {
        this.uvs = uvs;
    }

    /** The color to tint the mesh. */
    #if !spine_no_inline inline #end public function getColor():Color {
        return color;
    }

    /** The name of the texture region for this attachment. */
    #if !spine_no_inline inline #end public function getPath():String {
        return path;
    }

    #if !spine_no_inline inline #end public function setPath(path:String):Void {
        this.path = path;
    }

    /** The number of entries at the beginning of {@link #vertices} that make up the mesh hull. */
    #if !spine_no_inline inline #end public function getHullLength():Int {
        return hullLength;
    }

    #if !spine_no_inline inline #end public function setHullLength(hullLength:Int):Void {
        this.hullLength = hullLength;
    }

    #if !spine_no_inline inline #end public function setEdges(edges:ShortArray):Void {
        this.edges = edges;
    }

    /** Vertex index pairs describing edges for controling triangulation. Mesh triangles will never cross edges. Only available if
     * nonessential data was exported. Triangulation is not performed at runtime. */
    #if !spine_no_inline inline #end public function getEdges():ShortArray {
        return edges;
    }

    /** The width of the mesh's image. Available only when nonessential data was exported. */
    #if !spine_no_inline inline #end public function getWidth():Float {
        return width;
    }

    #if !spine_no_inline inline #end public function setWidth(width:Float):Void {
        this.width = width;
    }

    /** The height of the mesh's image. Available only when nonessential data was exported. */
    #if !spine_no_inline inline #end public function getHeight():Float {
        return height;
    }

    #if !spine_no_inline inline #end public function setHeight(height:Float):Void {
        this.height = height;
    }

    /** The parent mesh if this is a linked mesh, else null. A linked mesh shares the {@link #bones}, {@link #vertices},
     * {@link #regionUVs}, {@link #triangles}, {@link #hullLength}, {@link #edges}, {@link #width}, and {@link #height} with the
     * parent mesh, but may have a different {@link #name} or {@link #path} (and therefore a different texture). */
    #if !spine_no_inline inline #end public function getParentMesh():MeshAttachment {
        return parentMesh;
    }

    /** @param parentMesh May be null. */
    #if !spine_no_inline inline #end public function setParentMesh(parentMesh:MeshAttachment):Void {
        this.parentMesh = parentMesh;
        if (parentMesh != null) {
            bones = parentMesh.bones;
            vertices = parentMesh.vertices;
            regionUVs = parentMesh.regionUVs;
            triangles = parentMesh.triangles;
            hullLength = parentMesh.hullLength;
            worldVerticesLength = parentMesh.worldVerticesLength;
            edges = parentMesh.edges;
            width = parentMesh.width;
            height = parentMesh.height;
        }
    }

    /** When this is a linked mesh (see {@link #parentMesh}), if true, any {@link DeformTimeline} for the {@link #parentMesh} is
     * also applied to this mesh. If false, this linked mesh may have its own deform timelines.
     * <p>
     * See {@link #applyDeform(VertexAttachment)}. */
    #if !spine_no_inline inline #end public function getInheritDeform():Bool {
        return inheritDeform;
    }

    #if !spine_no_inline inline #end public function setInheritDeform(inheritDeform:Bool):Void {
        this.inheritDeform = inheritDeform;
    }
}