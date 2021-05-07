import { expect } from "chai";
import sinon, { SinonStub } from "sinon";
import * as redisActions from "../functions/redis/actions";
import * as getters from "../functions/fetch";
import { Result, ResultType, Status } from "../lib/result";
import { ElmLangPackage } from "../functions/types";
import { getElmPackages } from "../functions/api";
import redisClientResult from "../functions/redis/client";
import { IPromisifiedRedis } from "../functions/redis/types";
import { afterEach } from "mocha";

describe("api", () => {
  if (redisClientResult.Status === Status.Err) {
    throw new Error("Could not connect to redis client");
  }

  const client = redisClientResult.data;
  let elmPackagesCacheStub: SinonStub<
    [client: IPromisifiedRedis],
    Promise<ResultType<ElmLangPackage[]>>
  >;
  let fetchElmPackagesStub: SinonStub<
    [],
    Promise<ResultType<ElmLangPackage[]>>
  >;
  let setElmPackagesCacheStub: SinonStub<
    [packages: ElmLangPackage[], client: IPromisifiedRedis],
    Promise<boolean>
  >;

  beforeEach(() => {
    elmPackagesCacheStub = sinon.stub(redisActions, "getElmPackagesCache");
    fetchElmPackagesStub = sinon.stub(getters, "fetchElmPackages");
    setElmPackagesCacheStub = sinon.stub(redisActions, "setElmPackagesCache");
    client.FLUSHALL();
  });

  afterEach(() => {
    elmPackagesCacheStub.restore();
    fetchElmPackagesStub.restore();
    setElmPackagesCacheStub.restore();
    client.FLUSHALL();
  });

  describe("getElmPackages", () => {
    it("fetches elm packages from cache", async () => {
      elmPackagesCacheStub.returns(
        Promise.resolve(
          Result<ElmLangPackage[]>().Ok([
            { name: "Confidenceman02/elm-animate-height" },
          ])
        )
      );
      fetchElmPackagesStub.returns(
        Promise.resolve(
          Result<ElmLangPackage[]>().Ok([
            { name: "Confidenceman02/elm-animate-height" },
          ])
        )
      );

      const elmPackages = await getElmPackages(client);

      expect(elmPackagesCacheStub.called);
      expect(fetchElmPackagesStub.notCalled);
      expect(elmPackages).to.deep.eq({
        Status: Status.Ok,
        data: [{ name: "Confidenceman02/elm-animate-height" }],
      });
    });

    it("fetches elm packages from elm-lang and caches the result", async () => {
      elmPackagesCacheStub.returns(Promise.resolve(Result().Err));
      fetchElmPackagesStub.returns(
        Promise.resolve(
          Result<ElmLangPackage[]>().Ok([
            { name: "Confidenceman02/elm-animate-height" },
          ])
        )
      );

      const elmPackages = await getElmPackages(client);

      expect(fetchElmPackagesStub.called);
      expect(elmPackages).to.deep.eq({
        Status: Status.Ok,
        data: [{ name: "Confidenceman02/elm-animate-height" }],
      });
      expect(setElmPackagesCacheStub.called);
    });
  });
});
