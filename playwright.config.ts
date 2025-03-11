import { defineConfig } from '@playwright/test';

export default defineConfig({
  testDir: './tests/e2e',
  timeout: 30000,
  use: {
    headless: true,  // Run tests in headless mode
    baseURL: 'http://localhost:8000', // Set your Laravel app URL
    viewport: { width: 1280, height: 720 }, // Default viewport size
  },
  projects: [
    {
      name: 'chromium',
      use: { browserName: 'chromium' },
    },
    {
      name: 'firefox',
      use: { browserName: 'firefox' },
    },
    {
      name: 'webkit',
      use: { browserName: 'webkit' },
    },
    {
      name: 'Mobile Chrome',
      use: { browserName: 'chromium', viewport: { width: 375, height: 812 } },
    },
    {
      name: 'Mobile Safari',
      use: { browserName: 'webkit', viewport: { width: 375, height: 812 } },
    },
  ],
});
