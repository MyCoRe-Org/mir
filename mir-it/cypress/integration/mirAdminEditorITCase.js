describe('MIR Admin Editor IT Case', function() {
    beforeEach(function() {
        cy.visit('http://localhost:9107/mir')
        cy.url().should('include', 'content')
        cy.title().should('eq', 'Willkommen bei MIR!')
        cy.contains('Zugriff verweigert').should('not.be.visible')

        cy.contains('Anmelden').click()
        cy.url().should('include', 'MCRLoginServlet')
        cy.title().should('eq', 'Anmelden mit lokaler Nutzerkennung')
        cy.get('input[name="uid"]').clear().type('administrator')
        cy.get('input[name="pwd"]').clear().type('alleswirdgut')
        cy.get('button[name="LoginSubmit"]').click()

        cy.get('#currentUser').should('contain', 'administrator')
    })

    it('Test Base Validation', function () {
        cy.contains('Dokumente einreichen').click()
        cy.contains('Publizieren').click()
        cy.url().should('include', 'editor')
        cy.title().should('eq', 'MODS-Dokument erstellen')

        cy.get('button[type="submit"]:contains("Speichern")').click()

        cy.contains('Bitte geben Sie einen Titel ein.').should('be.visible')
        cy.get('textarea[name$="mods:title"').parents('.form-group').should('has.class','has-error');
        cy.contains('Bitte wählen Sie eine passende SDNB-Kategorie aus.').should('be.visible')
        cy.get('select[name$="mods:classification"').parents('.form-group').should('has.class','has-error');
        cy.contains('Bitte geben Sie an, mit welchen Rechten die Publikation nachgenutzt werden kann.').should('be.visible')
        cy.get('select[name$="mods:accessCondition[3]"').parents('.form-group').should('has.class','has-error');
        cy.contains('Bitte wählen Sie den Publikationstyp (Genre) aus.').should('be.visible')
        cy.get('select[name$="mods:genre/@valueURIxEditor"').parents('.form-group').should('has.class','has-error');
    })

    it('Test full Document', function () {
        cy.contains('Dokumente einreichen').click()
        cy.contains('Publizieren').click()
        cy.url().should('include', 'editor')
        cy.title().should('eq', 'MODS-Dokument erstellen')

        cy.get('button[name*="mods:genre"][name*="_xed_submit_insert"]').click()
        cy.get('select[name*="mods:genre"]').first().should('be.visible').select('article')
        cy.get('select[name*="mods:genre"]').last().should('be.visible').select('collection')

        cy.get('input[name$="mods:nonSort"][name*="mods:titleInfo"]').first().should('be.visible').type('Der')
        cy.get('select[name$="@xml:lang"][name*="mods:titleInfo"]').first().should('be.visible').select('de')
        cy.get('select[name$="@type"][name*="mods:titleInfo"]').first().should('be.visible').select('')
        cy.get('textarea[name$="mods:title"][name*="mods:titleInfo"]').first().should('be.visible').type('Test_Title')
        cy.get('textarea[name$="mods:subTitle"][name*="mods:titleInfo"]').first().should('be.visible').type('Test_Sub_Title')
        cy.get('button[name*="mods:titleInfo"][name*="_xed_submit_insert"]').click()

        cy.get('input[name$="mods:nonSort"][name*="mods:titleInfo"]').last().should('be.visible').type('The')
        cy.get('select[name$="@xml:lang"][name*="mods:titleInfo"]').last().should('be.visible').select('en')
        cy.get('select[name$="@type"][name*="mods:titleInfo"]').last().should('be.visible').select('alternative')
        cy.get('textarea[name$="mods:title"][name*="mods:titleInfo"]').last().should('be.visible').type('Test_Title_EN')
        cy.get('textarea[name$="mods:subTitle"][name*="mods:titleInfo"]').last().should('be.visible').type('Test_SUB_TITLE_EN')
        
        cy.get('input[name$="mods:displayForm"][name*="mods:name"]').first().should('be.visible').type('Neumann, Kathleen')
        cy.get('button[name*="mods:name"][name*="_xed_submit_insert"]').first().click()
        cy.get('input[name$="mods:displayForm"][name*="mods:name"]').last().should('be.visible').type('Mustermann, Hans')

        cy.get('input[name$="mods:namePart"][name*="mods:name"][placeholder="Titel der Konferenz ggf. mit Ort und Jahr oder Datum"').first().should('be.visible').type('Test-Konferenz, Jena, 01-01-2016')

        cy.get('select[name$="@type"][name*="mods:identifier"]').first().should('be.visible').select('doi')
        cy.get('input[name*="mods:identifier"]').first().should('be.visible').type('10.10.1038/testDOI')
        cy.get('button[name*="mods:identifier"][name*="_xed_submit_insert"]').first().click()
        
        cy.get('select[name$="@type"][name*="mods:identifier"]').eq(1).should('be.visible').select('urn')
        cy.get('input[name*="mods:identifier"]').eq(1).should('be.visible').type('urn:nbn:de:1111-20091210269')
        cy.get('button[name*="mods:identifier"][name*="_xed_submit_insert"]').eq(1).click()

        cy.get('select[name$="@type"][name*="mods:identifier"]').eq(2).should('be.visible').select('ppn')
        cy.get('input[name*="mods:identifier"]').eq(2).should('be.visible').type('222793902')

        cy.get('input[name$="mods:shelfLocator"]').first().should('be.visible').type('Test_Signature')
        
        cy.get('select[name$="@access"][name*="mods:url"]').first().should('be.visible').select('')
        cy.get('input[name*="mods:url"]').first().should('be.visible').type('http://google.de/')
        cy.get('button[name*="mods:url"][name*="_xed_submit_insert"]').first().click()
        
        cy.get('select[name$="@access"][name*="mods:url"]').eq(1).should('be.visible').select('preview')
        cy.get('input[name*="mods:url"]').eq(1).should('be.visible').type('http://apple.de/')

        cy.contains('Zugriffsberechtigung').parent('.form-group').find('select[name*="mods:accessCondition"]').should('be.visible').select('unlimited')
        cy.contains('Lizenz').parent('.form-group').find('select[name*="mods:accessCondition"]').should('be.visible').select('cc_by_4.0')
        
        cy.get('.search-topic-extended input[name*="mods:topic"]').first().should('be.visible').type('Schlagwort1')
        cy.get('button[name*="mods:topic"][name*="_xed_submit_insert"]').first().click()
        
        cy.get('.search-topic-extended input[name*="mods:topic"]').eq(1).should('be.visible').type('Schlagwort2')

        cy.get('select[name$="@xml:lang"][name*="mods:abstract"]').first().should('be.visible').select('de')
        cy.get('textarea[name*="mods:abstract"]').first().should('be.visible').type('Test_Text')
        cy.get('button[name*="mods:abstract"][name*="_xed_submit_insert"]').click()

        cy.get('select[name$="@xml:lang"][name*="mods:abstract"]').last().should('be.visible').select('en')
        cy.get('input[name$="@xlink:href"][name*="mods:abstract"]').last().should('be.visible').type('http://mycore.de/')

        cy.get('select[name$="@type"][name*="mods:note"]').first().should('be.visible').select('action')
        cy.get('textarea[name*="mods:note"]').first().should('be.visible').type('Test_Note')
        cy.get('button[name*="mods:note"][name*="_xed_submit_insert"]').click()

        cy.get('select[name$="@type"][name*="mods:note"]').last().should('be.visible').select('acquisition')
        cy.get('textarea[name*="mods:note"]').last().should('be.visible').type('Test_Note2')

        cy.get('input[name$="mods:placeTerm"]').first().should('be.visible').type('Place')

        cy.get('input[name$="mods:publisher"]').first().should('be.visible').type('publisher')

        cy.get('input[name$="mods:edition"]').first().should('be.visible').type('Edition')

        cy.get('input[name$="mods:physicalDescription/mods:extent"]').first().should('be.visible').type('50 Seiten')

        cy.get('select[name$="mods:typeOfResource/@mcr:categId"]').first().should('be.visible').select('typeOfResource:still_image')

        cy.get('input[name$="mods:coordinates"]').first().should('be.visible').type('11.591905873046787 50.936511349367855')
        
        cy.get('input[name$="mods:geographic"]').first().should('be.visible').type('GeographicPlace')

        cy.get('select[name*="mods:classification"]').first().should('be.visible').select('004')
        cy.get('button[name*="mods:classification"][name*="_xed_submit_insert"]').first().click()
        
        cy.get('select[name*="mods:classification"]').eq(1).should('be.visible').select('010')

        cy.get('button[type="submit"]:contains("Speichern")').click()
        cy.url().should('include', 'receive')
        cy.contains('Erfolgreich gespeichert!').should('be.visible')

        cy.contains('Test_Title').should('be.visible')
        cy.contains('Test_Sub_Title').should('be.visible')
        cy.contains('Test_Title_EN').should('be.visible')
        cy.contains('Test_SUB_TITLE_EN').should('be.visible')
        cy.contains('Neumann, Kathleen').should('be.visible')
        cy.contains('Mustermann, Hans').should('be.visible')
        cy.contains('Test-Konferenz, Jena, 01-01-2016').should('be.visible')
        cy.contains('Test_Signature').should('be.visible')
        cy.contains('http://google.de/').should('be.visible')
        cy.contains('http://apple.de/').should('be.visible')
        cy.contains('Test_Text').should('be.visible')
        cy.contains('Test_Note').should('be.visible')
        cy.contains('Test_Note2').should('be.visible')
        cy.contains('Place').should('be.visible')
        cy.contains('publisher').should('be.visible')
        cy.contains('Edition').should('be.visible')
        cy.contains('50 Seiten').should('be.visible')
        cy.contains('Bild (Standbild)').should('be.visible')
        cy.contains('11.591905873046787 50.936511349367855').should('be.visible')
        cy.contains('GeographicPlace').should('be.visible')
        cy.contains('004 Informatik').should('be.visible')
        cy.contains('010 Bibliographien').should('be.visible')
    })

    it('Search By Title', function () {
        cy.contains('Suche').click()
        cy.contains('einfach').click()
        cy.url().should('include', 'search')
        cy.title().should('eq', 'Einfache Suche über alle Publikationen')

        cy.get('#inputTitle1').should('be.visible').type('Test_Title')
        cy.contains('Suchen').click()

        cy.url().should('include', 'solr')
        cy.contains('Keine Dokumente gefunden').should('not.be.visible')
        cy.contains('Test_Title').should('be.visible')

    })

})