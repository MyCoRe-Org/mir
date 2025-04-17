import { defineConfig } from 'vite';
import externalGlobals from 'rollup-plugin-external-globals';
import eslint from 'vite-plugin-eslint';

export default defineConfig({
  plugins: [
    eslint(),
    externalGlobals({
      bootstrap: 'window.bootstrap',
    }),
  ],
  build: {
    rollupOptions: {
      input: {
        user: 'src/user.ts',
        'result-list': 'src/result-list.ts',
        metadata: 'src/metadata.ts',
      },
      output: {
        entryFileNames: '[name].js',
        chunkFileNames: '[name].[hash].js',
        assetFileNames: '[name].[ext]',
        dir: '../../../target/classes/META-INF/resources/js/mir',
      },
    },
  },
});
