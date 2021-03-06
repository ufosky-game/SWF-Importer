//
// Flump - Copyright 2013 Flump Authors

package flump.export {

import com.threerings.util.FileUtil;

import flash.events.Event;
import flash.events.MouseEvent;
import flash.filesystem.File;

import spark.components.Button;
import spark.components.Label;

import react.Signal;

public class DirChooser
{
    public const changed :Signal = new Signal(File);

    public function DirChooser (initial :File, selector :Label, button :Button)
    {
        _selector = selector;
        button.addEventListener(MouseEvent.CLICK, function (..._) :void {
            // Use a new File object to browse on as browseForDirectory modifies the object it uses
            var browser :File = dir;
            if (dir == null) { browser = File.documentsDirectory; }
            browser.addEventListener(Event.SELECT, function (..._) :void {
                dir = browser;
                changed.emit(dir);
            });
            browser.browseForDirectory("Select Directory");
        });
        dir = initial;
		
	
    }

    /** The selected directory or null if none has been selected. */
    public function get dir () :File { return _dir == null ? null : new File(_dir); }

    public function set dir (dir :File) :void {
        if (dir != null) {
            _dir = dir.nativePath;
			_selector.visible = true;
            _selector.text = unescape("..." + File.separator + FileUtil.stripPathAndDotSuffix(dir.url.toString()));
        } else {
            _dir = null;
            _selector.text = "<Not Set>";
			_selector.visible = false;
        }
		
    }

    protected var _dir :String;
    protected var _selector :Label;
}
}
