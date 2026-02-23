<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="rdf">

  <xsl:variable name="baseURI" select="document('classification:metadata:-1:children:mir_genres')/mycoreclass/label[@xml:lang='x-uri']/@text" />
  <xsl:template match="@rdf:type" priority="2">
    <xsl:choose>
      <xsl:when test="@rdf:resource='http://purl.org/ontology/bibo/Periodical'">
        <mods:genre authorityURI="{$baseURI}" valueURI="{$baseURI}#journal" type="intern" />
      </xsl:when>
      <xsl:when test="@rdf:resource='http://purl.org/ontology/bibo/Series'">
        <mods:genre authorityURI="{$baseURI}" valueURI="{$baseURI}#series" type="intern" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>
          Unknown rdf-Type:
          <xsl:value-of select="." />
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>