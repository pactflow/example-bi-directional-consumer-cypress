import React from 'react';
import ReactDOM from 'react-dom/client';
import { BrowserRouter, Route, Routes } from 'react-router-dom';
import './index.css';
import App from './App';
import ProductPage from './ProductPage';
import ErrorPage from './ErrorPage';

const root = ReactDOM.createRoot(document.getElementById('root'));

root.render(
  <BrowserRouter>
    <Routes>
      <Route path="/error" element={<ErrorPage />} />
      <Route path="/products/:id" element={<ProductPage />} />
      <Route path="/products" element={<App />} />
      <Route path="/" element={<App />} />
    </Routes>
  </BrowserRouter>
);
