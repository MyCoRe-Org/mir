import { defineConfig } from 'vite';
import eslint from 'vite-plugin-eslint';

export default defineConfig({
  plugins: [eslint()],
  build: {
    rollupOptions: {
      input: {
        'editor-funding': 'src/editor/funding/entry.ts',
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
