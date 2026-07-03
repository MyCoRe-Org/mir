package org.mycore.mir.it.tests;

import java.io.IOException;
import java.util.List;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.mycore.mir.it.controller.MIRBasketController;
import org.mycore.mir.it.controller.MIRSearchController;
import org.mycore.mir.it.controller.MIRUserController;
import org.mycore.mir.it.model.MIRSearchTestDataLoader;

/**
 * Integration test for the object basket (see MIR-1633).
 * <p>
 * Verifies three regressions of the XSLT/Saxon migration:
 * <ol>
 *   <li>the object page reflects the real basket membership (add vs. remove button),</li>
 *   <li>the basket display page renders the entries with the {@code basketContent} template instead of
 *       dumping the raw object text,</li>
 *   <li>the search result hit reflects the real basket membership (basket type {@code objects}).</li>
 * </ol>
 */
public class MIRBasketITCase extends MIRITBase {

    private static final String OBJECT_ID = "mir_mods_00010001";

    private static final String OBJECT_ID_2 = "mir_mods_00010002";

    private static final String OBJECT_TITLE = "Untersuchungen zur Entwicklung moderner Bibliotheken";

    private MIRBasketController basketController;

    @Before
    public final void init() throws IOException, InterruptedException {
        MIRSearchTestDataLoader searchTestDataLoader = new MIRSearchTestDataLoader();
        searchTestDataLoader.lazyLoadData(getDriver());

        String appURL = getAPPUrlString();
        MIRUserController userController = new MIRUserController(getDriver(), appURL);
        userController.logoutIfLoggedIn();
        userController.loginAs(MIRUserController.ADMIN_LOGIN, MIRUserController.ADMIN_PASSWD);

        this.basketController = new MIRBasketController(getDriver(), appURL);
        // start from a known empty basket
        this.basketController.clearBasket();
    }

    @Test
    public void testBasket() {
        // 1. object page: object is not in the basket -> "add" button must be shown
        basketController.openObjectPage(OBJECT_ID);
        Assert.assertFalse("Object page must show the add button when the object is not in the basket",
            basketController.isObjectInBasketAccordingToObjectPage());

        // 2. add the object -> object page must now show the "remove" button
        basketController.addToBasketViaObjectPage();
        Assert.assertTrue("Object page must show the remove button after the object was added to the basket",
            basketController.isObjectInBasketAccordingToObjectPage());

        // 3. basket display page must render the entry via the basketContent template, not as raw text
        basketController.openBasket();
        Assert.assertTrue("Basket must render the object with the formatted hit layout (a hit_title link), "
            + "not as raw text", basketController.isObjectRenderedInBasket(OBJECT_ID));

        // 4. search result hit must reflect the basket membership (basket type 'objects')
        MIRSearchController searchController = new MIRSearchController(getDriver(), getAPPUrlString());
        searchController.simpleSearchBy(OBJECT_TITLE, null, null, null, null);
        Assert.assertTrue("Search result hit must show the remove-from-basket link for an object in the basket",
            basketController.isObjectInBasketAccordingToSearchHit(OBJECT_ID));

        // 5. remove again -> object page must show the "add" button
        basketController.clearBasket();
        basketController.openObjectPage(OBJECT_ID);
        Assert.assertFalse("Object page must show the add button after the basket was cleared",
            basketController.isObjectInBasketAccordingToObjectPage());
    }

    @Test
    public void testBasketOrdering() {
        // add two objects: the basket appends, so the initial order is [OBJECT_ID, OBJECT_ID_2]
        basketController.addObjectToBasket(OBJECT_ID);
        basketController.addObjectToBasket(OBJECT_ID_2);

        basketController.openBasket();
        Assert.assertEquals("Basket order after adding both objects",
            List.of(OBJECT_ID, OBJECT_ID_2), basketController.getBasketEntryOrder());

        // move the first entry down -> order must become [OBJECT_ID_2, OBJECT_ID]
        basketController.moveDown(OBJECT_ID);
        Assert.assertEquals("Basket order after moving the first entry down",
            List.of(OBJECT_ID_2, OBJECT_ID), basketController.getBasketEntryOrder());

        // move it up again -> order must be back to [OBJECT_ID, OBJECT_ID_2]
        basketController.moveUp(OBJECT_ID);
        Assert.assertEquals("Basket order after moving the entry up again",
            List.of(OBJECT_ID, OBJECT_ID_2), basketController.getBasketEntryOrder());
    }
}
