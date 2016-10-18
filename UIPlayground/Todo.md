Todo
====

Non exhaustive list of things that could be improved.

Power Off
---------
- Fix view layout now that we are properly positioning the views below the nav bar
- The timing curves for various animations could be tuned to more closely match the iOS animations:
    - The "slide to power off" shimmer look doesn't quite match the one on iOS.
    - The "slide to power off" shimmer should begin at the beginning immediately after the slider animates back to the start position.
    - The power off thumb button should animate to black after/while slider moves to the end position.


App Cards
---------
- Card swipe up should only move the card portion and not the icon and label. To do this the carousel could have a special view with an aux view that stays put and a body that moves.
- Cards (including icon and app name label) don't scale properly based on current screen size.
- Panning the bottom or top of carousel view should also cause the cards to move.
- Don't allow swiping away of spring board card.
- Panning a card from the middle to the edge causes the pan to lose the card from under the panning finger.
- After horizontal pan has ended, cards should settle back in predefined "bucket" locations.
- Lazily fetch card data (screenshot, icon, etc) just before views are seen to reduce memory footprint.
- When sliding down first card, the cards behind it should show up.

Spring Board
------------
- Refine launch animation curve to better match the iOS animation curve.
- Rounded corner animation during launch should go to 0 earlier than when then animation finishes.
- Make the UIPageControl dots less transparent.
- Reduce time taken to build up launch animation.
- No delay when tapping the app icon. It should turn dark immediately.
