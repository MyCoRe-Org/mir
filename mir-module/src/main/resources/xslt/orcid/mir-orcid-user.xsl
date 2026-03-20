<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:include href="resource:xslt/orcid/mir-orcid.xsl"/>

  <xsl:param name="MCR.ORCID2.User.TrustedNameIdentifierTypes" select="''"/>
  <xsl:param name="currentUser" select="document('user:current')/user"/>
  <xsl:variable name="isGuestUser" select="$currentUser/@name = 'guest'"/>

  <xsl:variable name="userOrcids" as="xs:string*">
    <xsl:if test="$isOrcidEnabled and not($isGuestUser)">
      <xsl:for-each select="$currentUser/attributes/attribute[starts-with(@name, 'id_orcid')]">
        <xsl:sequence select="string(@value)"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="userIds" as="xs:string*">
    <xsl:if test="$isOrcidEnabled and not($isGuestUser)">
      <xsl:for-each select="$currentUser/attributes/attribute[starts-with(@name, 'id_')]">
        <xsl:sequence select="concat(substring(@name, 4), ':', @value)"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="hasLinkedOrcidCredential"
    select="$isOrcidEnabled
            and not($isGuestUser)
            and count($currentUser/attributes/attribute[starts-with(@name, 'orcid_credential')]) &gt; 0"/>

  <xsl:variable name="trustedIdTypes" select="tokenize($MCR.ORCID2.User.TrustedNameIdentifierTypes, ',') ! normalize-space(.)[. != '']"/>

  <xsl:template name="check-current-user-has-trusted-matching-id">
    <xsl:param name="nameIds"/>
    <xsl:variable name="matchingTrustedIds">
      <xsl:call-template name="get-matching-trusted-ids">
        <xsl:with-param name="idsA" select="$userIds"/>
        <xsl:with-param name="idsB" select="$nameIds"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="exists($matchingTrustedIds/str)"/>
  </xsl:template>

  <xsl:template name="get-matching-trusted-ids">
    <xsl:param name="idsA"/>
    <xsl:param name="idsB"/>
    <xsl:if test="count($trustedIdTypes) &gt; 0">
      <xsl:variable name="trustedIdsA" as="xs:string*">
        <xsl:for-each select="$idsA[substring-before(., ':') = $trustedIdTypes]">
          <xsl:sequence select="string(.)"/>
        </xsl:for-each>
      </xsl:variable>
      <xsl:for-each select="$idsB[. = $trustedIdsA]">
        <str><xsl:value-of select="."/></str>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
