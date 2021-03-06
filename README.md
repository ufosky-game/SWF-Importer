SWF Importer 
===================

Convert your Flash animations to SpriteBuilder.

Looking for support? Please visit the [SpriteBuilder Forum](http://forum.spritebuilder.com/).

## Download

The easiest way to get started is to download the app please see [Releases](https://github.com/cocojoe/Flash2CCB/releases) for a binary.

If you want to try it right now, then download the conversion ready [Tutorial Content](https://github.com/cocojoe/SWF-Importer/tree/master/Tutorial%20Content). Then skip to the Conversion section of this Readme for more information.

## Want to roll you rown?
The easiest way to build this app is to use Adobe Flash Builder 4.7+:  
 - Simply checkout this repository and then select `File/Import Flash Build Project`.  
 - Select the repository folder and click `Finish`.
 - Then select `Run/Run`.

You could possibly use [Apache Flex](http://flex.apache.org/) to build, however this is an exercise for the reader.

## Conversion Tutorial

This tutorial will cover the process of converting an existing FLA animation to [SpriteBuilder](http://www.spritebuilder.com/), you will be using some awesome artwork kindly donated by Vincent Le Quang, Melissa Wallace and Anna Klonoff. 

 - [Pika](https://github.com/jacklehamster/herosmasks/raw/master/Vincent/Flash/pika.fla)

`Note:` You will require both FLA source files and the published SWF for any content you wish to convert.

## Preperation

Open pika.fla (CS5+), you should see a few funky looking creatures in various colours.  To keep things clean create a `New Document` and select `ActionScript 3.0`, I called it bluebeast.fla.

Select the blue creature from `pika.fla` and copy this into the new `bluebeast.fla` document. 

Double click the `Pika run` symbol from the library.

Hit play to watch this majestic beast run like the wind, would make a nice endless runner character....

## Getting ready to export

**Step 1)** In the library view open properties for Pika run and ensure advanced options are expanded, tick the `Export for ActionScript`, then tick `Export in frame 1`, the base class should be `flash.display.MovieClip`.

Great this will now be picked up as an animation for the conversion tool, you then need to ensure all of the component parts of this animation can be exported as textures.  You can see various symbols such as Eye, EarFront and Horn in the Library view.

**Step 2)** Select all of the symbols from `BackLeg` down to `Tail`, ensure `Pika Run` is not part of this group selection and then edit properties.

**Step 3)** Tick `type` and ensure `Movie Clip` is selected from the drop down.  Tick `Export for Actionscript` and change the dropdown to `Yes`, don't worry about any warnings. Tick `Export in frame 1` andchange the dropdown to `Yes`.  Tick the `Base class` and enter `flash.display.Sprite`. Hit OK.

**Step 5)** Hit Publish

Ok you will most likely have some `Compiler Errors`. Not a problem, let's fix this right now, double click the first error message. A window will popup, clear the text `stop();`, close that window and save. Hit Publish again, great, it should be all working now.

## Conversion

Open SWF Importer

**Step 1)** Select the directory containing your bluebeast FLA and published SWF files. (I find it best to put these files in their down directory)

You should see `bluebeast` listed in the **Conversion Summary**, if valid does not say Yes then you need to go back and check you followed the previous steps correctly.

**Step 2)** Select an export directory, if you want to export into an existing SpriteBuilder project then select the `SpriteBuilder Resources` folder inside the desired `.spriteBuilder` project.

`Note:` As of SpriteBuilder 1.2 this folder will be `Packages\SpriteBuilder Resources.sbpack`

**Step 3)** Select the bluebeast and hit `Preview`, looking good. Close this window.

**Step 4)** Hit Export All.

You should now have a file called bluebeast_pikarun.ccb and a bluebeastAssets folder in your export directory. If you exported directly into your project these files will now appear in your project resources.

## SpriteBuilder

Great let's see these in action in SpriteBuilder. If you didn't drop these straight into an existing SpriteBuilder project, you can easily create one try it.

`Note:` The CCB export has been tested against SpriteBuilder 1.1

**Step 1)** Create a new project, I called it 'bluedemo', it will open up the MainScene.  Right click on `MainScene.ccb` in the File view and select `Show in Finder`.

**Step 2)** Copy the files from the export into this directory and then click back to the SpriteBuilder view. In a couple of seconds you will see `bluebeat_pikarun.ccb` appear in `File view` tab.

**Step 3)** Open this CCB and hit play, you should see the bluebeast running. That's it! 

## Credits

- The guys that did a load of hardwork, [Three Rings](https://github.com/threerings)
- SWF Importer/Ux/Conversion Tutorial, [Martin Walsh](http://github.com/cocojoe)
- Tutorial Flash content: Vincent Le Quang, Anna Klonoff and Melissa Wallace

### Maintainers

- [Martin Walsh](http://github.com/cocojoe)
- [Support Forum](http://forum.spritebuilder.com/)

## License

See the LICENSE file for more info.
