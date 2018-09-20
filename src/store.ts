
import dotProp from "dot-prop";
import { EventEmitter } from "events";
import extend from "lodash/extend";

export class Store extends EventEmitter {
  private data: object;
  private defaults: object;

  constructor(data?: object) {
    super();
    this.data = data || {};
    this.defaults = {};
  }

  public setDefaults(values: object) {
    extend(this.defaults, values);
  }

  public get(key: string) {
    const val = dotProp.get(this.data, key);
    if (typeof val === "undefined") {
      return dotProp.get(this.defaults, key);
    }
    return val;
  }

  public set(key: string, value: any, forceUpdate: boolean = false) {
    if (forceUpdate == null) { forceUpdate = false; }
    const old = this.get(key);
    const edited = dotProp.set(this.data, key, value);
    if (forceUpdate || (old !== value)) {
      this._update(key, value);
    }
    return edited;
  }

  public del(key: string) {
    const removed = dotProp.delete(this.data, key);
    this._update(key);
    return removed;
  }

  public toggle(key: string) {
    return this.set(key, !this.get(key));
  }

  private  _update(key: string, value?: any) {
    if (key) {
      this.emit(`updated.${key}`, value);
    } else {
      this.emit("updated");
    }
  }
}
