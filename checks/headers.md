# Headers

What a page served over HTTP tells the browser to refuse: scripts from
where they should not come, being framed by another site, a downgrade to
plain HTTP, a guessed content type. Without them, one hole in the page
(a value written as HTML, a script tag slipped in) can run anything, and
the browser has been told nothing that would stop it.

## What it holds

That the built thing, as served, sends:

- **a Content Security Policy** whose `script-src` has no
  `'unsafe-inline'` and no `'unsafe-eval'`. What has to run inline is
  allowed by a nonce or a hash. A policy that allows inline scripts does
  little a policy is for.
- **`frame-ancestors`** in the policy, saying who may frame the page,
  with `X-Frame-Options` beside it for older browsers
- **`Strict-Transport-Security`**, on HTTPS
- **`X-Content-Type-Options: nosniff`**
- **a `Referrer-Policy`**

They are read from a response from the built thing, as a browser would
get it, not from the config meant to set them: a header set in the wrong
place, or stripped by a proxy, is not sent.

## Its smallest form

    // smoke/headers.spec.ts, against the built thing served as it will be
    test('the page is served with its headers', async ({ request }) => {
      const res = await request.get('/');
      const csp = res.headers()['content-security-policy'] ?? '';
      expect(csp).toContain("frame-ancestors 'none'");
      expect(csp).not.toMatch(/script-src[^;]*'unsafe-(inline|eval)'/);
      expect(res.headers()['x-content-type-options']).toBe('nosniff');
      expect(res.headers()['referrer-policy']).toBeTruthy();
    });

    # once deployed, a second opinion
    npx @mdn/mdn-http-observatory example.com

The HTTP Observatory moved to MDN in 2024
(developer.mozilla.org/en-US/observatory). Its CLI and its API at
`observatory-api.mdn.mozilla.net` grade a live host.

## Seen failing

- `'unsafe-inline'` added to `script-src`, and the test is seen to fail
  on the response.
- `frame-ancestors` removed, and the test is seen to fail.
- The header set in config but not served (the dev server, not the
  build), and the test, run against the build, is seen to catch it.

## Where it cannot apply

- **A static host that cannot set headers.** GitHub Pages offers no
  setting for them. The policy is set by
  `<meta http-equiv="Content-Security-Policy">` in the page, which cannot
  carry `frame-ancestors`, `sandbox` or `report-uri`. What cannot be set
  is said under _What is not held_.
- **A package or a CLI** serves nothing, and has nothing here.
- **A service's API** that serves no HTML still sends `nosniff`, HSTS and
  a restrictive CSP, so that a response opened in a browser cannot run.
