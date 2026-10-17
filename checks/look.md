# The look

What the user sees, held to pictures taken before and looked at. Every
other check is on what the thing does; without this nothing notices a
colour gone muddy, a label off the edge, or one layer drawn over another.

## What it holds

That each scene, set through the test API with chance seeded and time
stepped a fixed amount, draws what it drew before: at a phone's width and
a desk's, in every theme.

What moves only to be seen moves by the stepped time too, so the same
machine draws the same pixels every run. Where it does not, the drift is
measured before a threshold is chosen: the scene drawn many times on pages
just started, and the pixels that move counted at each threshold. A share
of the picture is never forgiven: a button is a few hundred pixels of a
million.

A picture is looked at, not only compared. One written again is read in
full for what it is there to show, and the commit that wrote it says so.

## Its smallest form

    // smoke/look.spec.ts
    for (const width of [390, 1280]) {
      test(`the arena with three balls, ${width} wide`, async ({ page }) => {
        await page.setViewportSize({ width, height: 800 });
        await start(page, { seed: 3 });
        await page.evaluate(() => { game.pause(); game.place('ball', 0, 2); game.step(30); });
        await expect(page).toHaveScreenshot(`arena-${width}.png`, { threshold: 0.02, maxDiffPixels: 0 });
      });
    }

    npm run look           the scenes against the pictures
    npm run look:update    the pictures written again, after a change meant to alter them

A failure leaves three pictures: the one it was held to, what was drawn,
and the difference. All three are looked at before deciding which is
right. A change in the thing shows as a shape; a machine's own drift shows
as scattered pixels.

The pictures are one machine's, and say so. Another GPU or font stack
draws them a little differently, and is not argued with from there.

## Seen failing

A colour token is changed by a little, and the look is seen to fail on
every scene that uses it. An element is moved by a few pixels, and the
scene it is in is seen to fail.

## Where it cannot apply

- **A package** with no picture has nothing here, and says so. One that
  draws (a chart library, a renderer) holds its own pictures.
- **A service** and **a CLI** hold their output instead: the response or
  the text, held to a file written before, and read when it changes.
- **Motion** is held by stepping to set points and taking a picture at
  each, and looked at moving by a person before it lands.
