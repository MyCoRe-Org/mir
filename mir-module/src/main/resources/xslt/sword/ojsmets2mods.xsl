<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:epdcx="http://purl.org/eprint/epdcx/2006-11-16/"
    exclude-result-prefixes="xs fn epdcx">
    
    <xsl:output method="xml"
        version="1.0"
        encoding="UTF-8"
        indent="yes" />
    
    <xsl:strip-space elements="*" />
    
    <xsl:mode on-no-match="shallow-skip" />
    
    <xsl:variable name="lang">
        <xsl:value-of select="'en'" />
    </xsl:variable>
    
    <xsl:template match="epdcx:description[@epdcx:resourceId='sword-mets-epdcx-1']">
        <mods:mods version="3.7">
            <xsl:apply-templates />
            <!-- set defaults -->
            <mods:genre authorityURI="http://www.mycore.org/classifications/mir_genres"
                        valueURI="http://www.mycore.org/classifications/mir_genres#article"
                        type="intern" />
            <mods:typeOfResource>text</mods:typeOfResource>
            <mods:language>
                <mods:languageTerm authority="rfc5646" type="code"><xsl:value-of select="$lang" /></mods:languageTerm>
            </mods:language>
            <mods:accessCondition type="use and reproduction"
                                  xlink:href="http://www.mycore.org/classifications/mir_licenses#rights_reserved" />
        </mods:mods>
    </xsl:template>
    
    <xsl:template match="epdcx:statement[@epdcx:propertyURI='http://purl.org/dc/elements/1.1/title']">
        <mods:titleInfo xml:lang="{$lang}">
            <mods:title><xsl:value-of select="epdcx:valueString" /></mods:title>
        </mods:titleInfo>
    </xsl:template>
    
    <xsl:template match="epdcx:statement[@epdcx:propertyURI='http://purl.org/dc/terms/abstract']">
        <mods:abstract xml:lang="{$lang}">
            <xsl:value-of select="epdcx:valueString" />
        </mods:abstract>
    </xsl:template>
    
    <xsl:template match="epdcx:statement[@epdcx:propertyURI='http://purl.org/dc/elements/1.1/creator']">
        <mods:name type="personal">
            <mods:displayForm><xsl:value-of select="epdcx:valueString" /></mods:displayForm>
            <mods:namePart type="family"><xsl:value-of select="substring-before(epdcx:valueString, ', ')" /></mods:namePart>
            <mods:namePart type="given"><xsl:value-of select="substring-after(epdcx:valueString, ', ')" /></mods:namePart>
            <mods:role>
                <mods:roleTerm authority="marcrelator" type="code">aut</mods:roleTerm>
            </mods:role>
        </mods:name>
    </xsl:template>
    
</xsl:stylesheet>