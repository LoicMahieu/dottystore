
import "jest";
import { Store } from "../store";

describe("Store", () => {
  it("is a class", () => expect(new Store()).toBeInstanceOf(Store));
});

describe("Store::get", () => {
  let store: Store;

  beforeEach(() => {
    store = new Store({
      bar: {
        foo: "bar",
      },
      baz: ["a", "b", "c"],
      foo: "bar",
      foobar: true,
    });
  });

  it("Can get a string", () => expect(store.get("foo")).toEqual("bar"));
  it("Can get an array", () => expect(store.get("baz")).toEqual(["a", "b", "c"]));
  it("Can get an object", () => expect(store.get("bar")).toEqual({foo: "bar"}));
  it("Can get a boolean", () => expect(store.get("foobar")).toEqual(true));
});

describe("Store::set", () => {
  let store: Store;

  beforeEach(() => {
    store = new Store();
  });

  const testWrite = (
    prop: string,
    value: any,
    equality: (data: object) => void,
    called: number = 1,
    forceUpdate?: boolean,
  ) => {
    const spy = jest.fn((data: object) => equality(data));
    store.once(`updated.${prop}`, spy);
    store.set(prop, value, forceUpdate);

    if (called) {
      expect(spy).toHaveBeenCalledTimes(called);
    } else {
      expect(spy).toHaveBeenCalledTimes(0);
    }

    equality(store.get(prop));
  };

  it("Can set a string", () => testWrite("foo", "bar", (v) => expect(v).toEqual("bar")));

  it("Can set a string already exists", () => testWrite("foo", "bar", ((v) => expect(v).toEqual("bar"))));

  it("Can get an array", () => testWrite("baz", ["a", "b", "c"], (v) => expect(v).toEqual(["a", "b", "c"])));

  it("Can get an object", () => testWrite("bar", {foo: "bar"}, (v) => expect(v).toEqual({foo: "bar"})));

  it("Can get a boolean", () => testWrite("foobar", true, (v) => expect(v).toEqual(true)));

  return describe("ForceUpdate", () => {
    it("Do not trigger save if set the same object", () => {
      const obj = {foo: "bar"};
      testWrite("obj", obj, (v) => expect(v).toEqual({foo: "bar"}));
      testWrite("obj", obj, ((v) => expect(v).toEqual({foo: "bar"})), 0);
    });

    return it("Trigger save if set the same object if forceUpdate = true", () => {
      const obj = {foo: "bar"};
      testWrite("obj", obj, (v) => expect(v).toEqual({foo: "bar"}));
      testWrite("obj", obj, ((v) => expect(v).toEqual({foo: "bar"})), 1, true);
    });
  });
});

describe("Store::toggle", () => {
  let store: Store;

  beforeEach(() => store = new Store());

  it("Toggle undefined to true", () => {
    store.toggle("to.exists");
    expect(store.get("to.exists")).toEqual(true);
  });

  it("Toggle false to true", () => {
    store.set("must.be.false", false);
    store.toggle("must.be.false");
    expect(store.get("must.be.false")).toEqual(true);
  });

  return it("Toggle true to false", () => {
    store.set("must.be.true", true);
    store.toggle("must.be.true");
    expect(store.get("must.be.true")).toEqual(false);
  });
});

describe("Store::del", () => {
  let store: Store;

  beforeEach(() => {
    store = new Store();
  });

  const testDelete = (prop: string, called: number = 1) => {
    const spy = jest.fn();
    store.once(`updated.${prop}`, spy);
    store.del(prop);

    if (called) {
      expect(spy).toHaveBeenCalledTimes(called);
    } else {
      expect(spy).toHaveBeenCalledTimes(0);
    }

    expect(store.get(prop)).toBeUndefined();
  };

  return it("Delete a string", () => {
    store.set("to.delete", "str");
    return testDelete("to.delete");
  });
});

describe("Store::setDefaults", () => {
  let store: Store;

  beforeEach(() => {
    store = new Store({
      some: {
        path1: "overwrite",
      },
    });
  });

  return it("Can set somes defaults", () => {
    store.setDefaults({
      some: {
        path: "foo:bar",
        path1: "bar:foo",
      },
    });
    store.set("some.path1", "overwrite");
    expect(store.get("some.path")).toEqual("foo:bar");
  });
});
