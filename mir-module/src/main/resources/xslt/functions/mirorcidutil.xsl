<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:mcrproperty="http://www.mycore.de/xslt/property"
  xmlns:mirorcidutil="http://www.mycore.de/xslt/mirorcidutil"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all">

  <xsl:function name="mirorcidutil:is-orcid-enabled" as="xs:boolean">
    <xsl:sequence select="mcrproperty:one('MCR.ORCID2.OAuth.ClientSecret') != ''" />
  </xsl:function>

  <xsl:function name="mirorcidutil:is-publishable-state" as="xs:boolean">
    <xsl:param name="state" as="xs:string" />

    <xsl:variable name="publish-states" select="
      tokenize(mcrproperty:one('MCR.ORCID2.Work.PublishStates'), ',') ! normalize-space(.)[. != '']
    " />

    <xsl:sequence select="$publish-states[. = $state] => exists()" />
  </xsl:function>

  <xsl:function name="mirorcidutil:get-name-ids" as="xs:string*">
    <xsl:param name="object" as="element(mycoreobject)" />

    <xsl:sequence select="$object//modsContainer/mods:mods/mods:name/mods:nameIdentifier/concat(@type, ':', .)" />
  </xsl:function>

  <xsl:function name="mirorcidutil:has-orcid-credential" as="xs:boolean">
    <xsl:param name="user" as="element(user)" />

    <xsl:sequence select="exists($user/attributes/attribute[starts-with(@name, 'orcid_credential')])" />
  </xsl:function>

  <xsl:function name="mirorcidutil:get-ids" as="xs:string*">
    <xsl:param name="user" as="element(user)" />
    <xsl:sequence select="
        $user/attributes/attribute[starts-with(@name, 'id_')]/concat(substring(@name, 4), ':', @value)
      " />
  </xsl:function>

  <xsl:function name="mirorcidutil:get-trusted-name-id-types" as="xs:string*">
    <xsl:sequence select="
      tokenize(mcrproperty:one('MCR.ORCID2.User.TrustedNameIdentifierTypes'), ',') ! normalize-space(.)[. != '']
    " />
  </xsl:function>

  <xsl:function name="mirorcidutil:get-orcids" as="xs:string*">
    <xsl:param name="user" as="element(user)" />

    <xsl:sequence select="$user/attributes/attribute[starts-with(@name, 'id_orcid')]/@value/string()" />
  </xsl:function>

  <xsl:function name="mirorcidutil:get-matching-trusted-ids" as="xs:string*">
    <xsl:param name="a" as="xs:string*" />
    <xsl:param name="b" as="xs:string*" />

    <xsl:variable name="name-id-types" select="mirorcidutil:get-trusted-name-id-types()" />

    <xsl:if test="exists($name-id-types)">
      <xsl:variable name="trusted-a" select="$a[substring-before(., ':') = $name-id-types]" />
      <xsl:sequence select="$b[. = $trusted-a]" />
    </xsl:if>
  </xsl:function>

  <xsl:function name="mirorcidutil:has-trusted-matching-id" as="xs:boolean">
    <xsl:param name="user" as="element(user)" />
    <xsl:param name="name-ids" as="xs:string*" />

    <xsl:sequence select="exists(mirorcidutil:get-matching-trusted-ids(mirorcidutil:get-ids($user), $name-ids))" />
  </xsl:function>

</xsl:stylesheet>
