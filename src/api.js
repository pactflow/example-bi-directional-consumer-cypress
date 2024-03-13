import axios from 'axios';
import { Product } from './product';

export class API {
  constructor(url) {
    if (!url) {
      url = process.env.REACT_APP_API_BASE_URL || 'http://localhost:3001';
    } else if (url.endsWith('/')) {
      url = url.slice(0, -1);
    }
    this.url = url;
  }

  withPath(path) {
    if (!path.startsWith('/')) {
      path = '/' + path;
    }
    return `${this.url}${path}`;
  }

  generateAuthToken() {
    // Consider using a more secure token generation mechanism
    return 'Bearer ' + new Date().toISOString();
  }

  async getAllProducts(id) {
    const url = id
      ? this.withPath(`/products?id=${id}`)
      : this.withPath('/products');

      const { data } = await axios.get(url, {
        headers: {
          Authorization: this.generateAuthToken(),
        },
      });
      return data.map((p) => new Product(p));
  }

  async getProduct(id) {
    const url = this.withPath(`/product/${id}`);
      const { data } = await axios.get(url, {
        headers: {
          Authorization: this.generateAuthToken(),
        },
      });
      return new Product(data);
  }
}

export default new API();
