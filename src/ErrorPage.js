import React from 'react';
import { useLocation } from 'react-router-dom';
import 'spectre.css/dist/spectre.min.css';
import 'spectre.css/dist/spectre-icons.min.css';
import 'spectre.css/dist/spectre-exp.min.css';
import Layout from './Layout';
import Heading from './Heading';

function ErrorPage() {
  const location = useLocation();
  const error = location.state?.error || ''; // Use optional chaining to handle potential undefined values

  return (
    <Layout>
      <Heading text="Sad times :(" href="/" />
      <div className="columns">
        <img
          className="column col-6"
          style={{ height: '100%' }}
          src={'./sad_panda.gif'}
          alt="sad_panda"
        />
        <pre className="code column col-6" style={{ wordWrap: 'break-word' }}>
          <code>{error}</code>
        </pre>
      </div>
    </Layout>
  );
}

export default ErrorPage;
