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
        'orcid-user': 'src/orcid-user.ts',
        'orcid-result-list': 'src/orcid-result-list.ts',
        'orcid-metadata': 'src/orcid-metadata.ts',
        'orcid-basket': 'src/orcid-basket.ts',
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
