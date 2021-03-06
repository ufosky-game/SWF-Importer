package flump.export
{

	import com.adobe.images.PNGEncoder;
	import com.threerings.util.FileUtil;
	import com.threerings.util.XmlUtil;
	
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.utils.IDataOutput;
	
	import flump.SwfTexture;
	import flump.mold.KeyframeMold;
	import flump.mold.MovieMold;
	import flump.xfl.XflLibrary;
	import flump.xfl.XflTexture;
		
	public class CCBFormat extends PublishFormat
	{
		public static const NAME :String = "CCB";
		
		public function CCBFormat (destDir :File, lib :XflLibrary, conf :ExportConf) {
			super(destDir, lib, conf);
			
			// Basename
			_assetname = FileUtil.stripPathAndDotSuffix(lib.location);
			
			// Texture Folder
			_assetDir  = _assetname + "Assets";
			_prefix    = "./";
		}
		
		override public function get modified () :Boolean {
			return true;
		}
		
		override public function publish () :void {
			const libExportDir :File = _destDir.resolvePath(_prefix + _assetDir + "/" + "resources-auto"); // SpriteBuilder Required for Auto Thumbs
			
			// Ensure any previously generated atlases don't linger
			if (libExportDir.exists) libExportDir.deleteDirectory(/*deleteDirectoryContents=*/true);
			libExportDir.createDirectory();
			
			// Extract/Write Individual Textures 
			var textures:Array = new Array(); 
			var SWFTexture: SwfTexture;
			var movie :MovieMold;
			
			// Check Configutration on Project
			trace(_conf.scale);
			
			// Animation Texture Frame
			for each (var tex :XflTexture in _lib.textures) {
				SWFTexture = (SwfTexture.fromTexture(_lib.swf, tex, _conf.quality, _conf.scale));
				textures.push(SWFTexture); // Add Texture
				Files.write( libExportDir.resolvePath(SWFTexture.symbol + ".png"), function (out :IDataOutput) :void {  out.writeBytes(PNGEncoder.encode(SWFTexture.toBitmapData())); });
			}
			
			// Flipbook Texture Frames
			for each (movie in _lib.movies) {
				if (!movie.flipbook) continue;
				for each (var kfm :KeyframeMold in movie.layers[0].keyframes) {
					SWFTexture = (SwfTexture.fromFlipbook(_lib, movie, kfm.index, _conf.quality, _conf.scale));
					textures.push(SWFTexture); // Add Texture
					Files.write( libExportDir.resolvePath(SWFTexture.symbol + ".png"), function (out :IDataOutput) :void {  out.writeBytes(PNGEncoder.encode(SWFTexture.toBitmapData())); });
				}
			}
			
			for each (movie in _lib.publishedMovies) {
				
				var movieXml :XML = movie.scale(_conf.scale).toXML();
				var Ref: String = ''; // @testing kFirst Frame Check
				var movieName :String = movieXml.@name;
				var frameRate: Number = _lib.frameRate;
				var animationLength: Number = 0;     // Default
				var maxAnimationLength: Number =0 ;  // Capture Max Timeline
				var boundingBox:Rectangle = new Rectangle(0,0,0,0);
				
				// CCB Per Animation
				var metaFile: File  = _destDir.resolvePath(_prefix + _assetname + "_" + movieXml.@name.toLowerCase() + "." + CCBFormat.NAME.toLowerCase());
				trace("Movie: "+ movieName + ", FPS: " + frameRate);
				
				// Write CCB (Skip Scene(s), UnSupported for now, add CCBFile support at some point.)
				if(metaFile.url.indexOf("scene")>=0)
					continue;
				
				// Start CCB Format
				var export :String = "";
				export+=CCBHelper.addHeader();
				export+=CCBHelper.startNode();

				// Parse Layers
				for each (var layer :XML in movieXml..layer) {
					
					trace("Layer: "+ layer.@name);
					
					// Reset Per Layer (Should all be same)
					animationLength = 0;
					
					// Layer Animation Frame Array
					var animation :Array = new Array();
					
					//Parse Key Frames 
					for each (var kf :XML in layer..kf) {
						
						if (XmlUtil.hasAttr(kf, "label")) {
							trace("Skip Label, Layer: " + layer.@name);
							continue;
						}
					
						// Check KF Valid
						if (XmlUtil.hasAttr(kf, "ref") || XmlUtil.hasAttr(kf, "duration")) {

							// Create Frame
							var frame: CCBFrame = new CCBFrame();
							
							// Name
							frame.layer = layer.@name.toString();
							
							if(XmlUtil.hasAttr(kf, "ref")) { 
								trace("KF: "+ kf.@ref);
								
								// Lookup Symbol Texture
								var width  :Number = 1;
								var height :Number = 1;
								for each (var TextureLookup: SwfTexture in textures) {
									if(TextureLookup.symbol==kf.@ref) {
										width  = TextureLookup.w;
										height = TextureLookup.h;
										break;
									}
								}
								
								// Symbol
								frame.symbol = kf.@ref.toString();
							} else if(XmlUtil.hasAttr(kf, "duration")) {
								// Visibility Toggle
								frame.visiblity = true;
							}

							// Duration
							if(kf.@duration.length()>0) { 
								frame.duration =  ( (60 / frameRate) * Number(kf.@duration) ) / 60; 
								animationLength+=frame.duration;
							}
							
							// Position
							if(XmlUtil.hasAttr(kf, "loc")) { 
								frame.flagPosition = true;
								frame.position     = kf.@loc.split(/,/);
								frame.position[0]  = Number(frame.position[0])/_conf.scale; 
								frame.position[1]  = (Number(frame.position[1])*-1)/_conf.scale;     // Flip Y
								
								// Min/Max Positions
								if(frame.position[0]>boundingBox.x) {
									boundingBox.x = frame.position[0];
								}
								if(frame.position[1]<boundingBox.y) {
									boundingBox.y = frame.position[1];
								}
								
							}
							
							// Anchor
							if(kf.@pivot.length()>0 && width && height) { 
								frame.anchor = kf.@pivot.split(/,/);
								frame.anchor[0] = frame.anchor[0]/width;
								frame.anchor[1] = 1 - (frame.anchor[1]/height);
							}
							
							// Scale
							if(kf.@scale.length()>0) { 
								frame.flagScale = true;
								frame.scale = kf.@scale.split(/,/);
							}
							
							// Skew / Rotation
							if(XmlUtil.hasAttr(kf, "skew")) { 
								frame.flagSkew = true;
								frame.skew = kf.@skew.split(/,/);
								
								frame.rotation[0] = frame.skew[0] * 180.0/Math.PI;
								frame.rotation[1] = frame.skew[1] * 180.0/Math.PI;
								
								if(frame.skew[0]!=0 && frame.skew[1]!=0)
								{
									frame.flagRotation = true;
								}
							}
							
							// Alpha
							if(XmlUtil.hasAttr(kf, "alpha")) {
								frame.flagOpacity = true;
								frame.opacity     = kf.@alpha;
							}
							
							// Tweened
							if(XmlUtil.hasAttr(kf, "tweened")) {
								if(kf.@tweened.toString()=="false") {
									frame.tweened = false;
								}
							}
							
							animation.push(frame);
							
							// Layer Name
							Ref = movieXml..layer.@name;

							
						}
						
					}
					
					// Requires at least 1 Frame
					if(animation.length>0) {
						
						// Build Animation
						var keyFrameExport:String = CCBHelper.addAnimation(animation,_assetDir);
						export+=keyFrameExport;
						trace("Exporting Layer: " + layer.@name);
						
						// Flags
						var fVisible:int = keyFrameExport.search("visible");
						
						
						// Hack required to ensure a basevalue spriteframe (or will bomb out runtime)
						for each (var tempFrame :CCBFrame in animation) {
							if(tempFrame.symbol!=null) {
								export+=CCBHelper.addSprite(tempFrame,_assetDir,fVisible);
								break;
							}
						}
						
					}
					
					// Update Max Timeline
					if(animationLength>maxAnimationLength) {
						maxAnimationLength = animationLength;
					}
					
				}
				
				// End CCB
				export+=CCBHelper.endNode();
				export+=CCBHelper.addFooter(maxAnimationLength);
				
				// Write Movie
				export = export.replace (/\s*\R/g, "\n");  // Remove Empty Lines
				Files.write(metaFile, function (out :IDataOutput) :void { out.writeUTFBytes(export); });
			}

		}
		
		protected var _assetname :String;
		protected var _prefix :String;
		protected var _assetDir :String;
		
	}
}

