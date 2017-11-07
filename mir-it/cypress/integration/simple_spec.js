describe('MIR Test', function() {
    it('Test Startseite', function () {
        cy.visit('http://localhost:9107/mir')
        cy.url().should('include', 'content')
    })
})
