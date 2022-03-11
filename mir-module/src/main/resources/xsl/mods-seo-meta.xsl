<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xalan="http://xml.apache.org/xalan"
                exclude-result-prefixes="xsl mods xlink xalan">

    <xsl:include href="mods-utils.xsl"/>

    <xsl:template match="mods:mods" mode="seo-meta">
        <xsl:apply-templates select="mods:abstract|mods:abstract/@xlink:href" mode="seo"/>
    </xsl:template>

    <xsl:template match="mods:abstract[not(@altFormat)] | mods:tableOfContents[not(@altFormat)] | mods:note" mode="seo">
        <meta>
            <xsl:attribute name="name">Description</xsl:attribute>
            <xsl:attribute name="content">
                <xsl:value-of select="substring(.,0,141)"/>
            </xsl:attribute>
        </meta>
    </xsl:template>

    <!-- suppress all else:-->
    <xsl:template match="*" mode="seo"/>

</xsl:stylesheet>
