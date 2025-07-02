// Vercel Edge Function to inject environment variables
export default function handler(req, res) {
  res.setHeader('Content-Type', 'application/javascript');
  res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
  
  // Return JavaScript that sets the window variables
  res.status(200).send(`
    window.SUPABASE_URL = '${process.env.NEXT_PUBLIC_SUPABASE_URL || ''}';
    window.SUPABASE_ANON_KEY = '${process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || ''}';
    
    // Debug log
    console.log('Environment variables loaded from Vercel:', {
      url: window.SUPABASE_URL ? 'Set' : 'Missing',
      key: window.SUPABASE_ANON_KEY ? 'Set' : 'Missing'
    });
  `);
}