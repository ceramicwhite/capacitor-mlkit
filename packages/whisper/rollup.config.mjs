import nodeResolve from '@rollup/plugin-node-resolve';

export default {
  input: 'dist/esm/index.js',
  external: ['@capacitor/core'],
  output: [
    {
      file: 'dist/plugin.js',
      format: 'iife',
      name: 'capacitorWhisper',
      globals: {
        '@capacitor/core': 'capacitorExports',
      },
      sourcemap: true,
      inlineDynamicImports: true,
    },
    {
      file: 'dist/plugin.cjs.js',
      format: 'cjs',
      sourcemap: true,
      inlineDynamicImports: true,
    },
  ],
  plugins: [
    nodeResolve({
      browser: true,
    }),
  ],
};