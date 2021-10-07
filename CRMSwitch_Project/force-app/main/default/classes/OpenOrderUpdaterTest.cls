@istest(seealldata=true)
private class OpenOrderUpdaterTest {
    private static testmethod void test() {
        OpenOrderUpdater oa = new OpenOrderUpdater();
        try {
            oa.execute(null);
        } catch(Exception ex) {
        }
        oa.start(null);
        List<SObject> scc = [select Id from Order limit 1];
        oa.execute(null, scc);
        oa.finish(null);
    }
}