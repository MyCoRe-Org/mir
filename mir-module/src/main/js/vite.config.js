import { defineConfig } from 'vite';

export default defineConfig({
  build: {
    rollupOptions: {
      input: {
        'user': 'src/user.ts',
        'result-list': 'src/result-list.ts',
        'metadata': 'src/metadata.ts',
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
