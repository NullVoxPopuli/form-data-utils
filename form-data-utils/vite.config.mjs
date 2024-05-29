import { resolve } from 'node:path';
import url from 'node:url';

import { defineConfig } from 'vite';
import dts from 'vite-plugin-dts';

const __dirname = url.fileURLToPath(new URL('.', import.meta.url));

export default defineConfig({
  build: {
    outDir: 'dist',
    target: ['esnext'],
    // In case folks debug without sourcemaps
    minify: false,
    sourcemap: true,
    lib: {
      // Could also be a dictionary or array of multiple entry points
      entry: resolve(__dirname, 'src/index.ts'),
      formats: ['es'],
      // the proper extensions will be added
      fileName: 'index',
    },
  },
  plugins: [
    dts({
      rollupTypes: true,
      outDir: 'declarations',
    }),
  ],
});
