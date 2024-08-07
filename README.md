# Godot Closed Captions

This AddOn allows you to dynamically create closed captions and subtitles following [BBC Guidance](https://www.bbc.co.uk/accessibility/forproducts/guides/subtitles/) for your godot game.

## How to install
1. Get it off the Godot Asset Store once it is available
   OR copy the `addons/closed_captions` into your addons folder
2. Enable the plugin in Project Settings.
3. Run `git lfs install` and `git lfs pull` to enjoy the demo scene.

## Usage
1. Use `CaptionedAudioStreamPlayer` instead of regular `AudioStreamPlayer` for any sound sources that need captioning.
2. Use the `SingleCaptionAudioStream` to assign a single `Caption` to a noise or a brief speech clip.
3. Use an Array of Captions held by the `MultiCaptionAudioStream` `Resource` to caption dialouge or longer speach clips.
4. Add a `CaptionDisplay` and the `CaptionServer` will display captions of audible sound sources. Choose `compact` to get a les intrusive version of the component ideal for showing ambient noises during gameplay.
5. Use Audio Busses to filter what `CaptionedAudioStreamPlayer` will be shown on any `CaptionDisplay`.

## Limitations
 1. This is an Acessability Plugin. It is not meant to be pretty. When you try to apply your own theme to the subtitles, please make it as acessible as you can and allow users to switch back.
 2. This Addon will sometimes not like things you are doing when they may collide with the guidelines. It will complain by showing node configuration warnings.
 3. Right now, this is still in development and directional audio players are not yet supported.
 4. I know: generating multi caption audio streams is a bit of a pain as of now. I will try to create a UI component for this, but that will take time.
