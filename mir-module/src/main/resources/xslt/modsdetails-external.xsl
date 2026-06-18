<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0"
  xmlns:datacite="http://datacite.org/schema/kernel-4"
  xmlns:mcracl="http://www.mycore.de/xslt/acl"
  xmlns:mcractionmapping="http://www.mycore.de/xslt/actionmapping"
  xmlns:mcrclassification="http://www.mycore.de/xslt/classification"
  xmlns:mcri18n="http://www.mycore.de/xslt/i18n"
  xmlns:mcrpi="http://www.mycore.de/xslt/pi"
  xmlns:mcrstringutils="http://www.mycore.de/xslt/stringutils"
  xmlns:miraccesskeyutil="http://www.mycore.de/xslt/miraccesskeyutil"
  xmlns:mods="http://www.loc.gov/mods/v3"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  exclude-result-prefixes="#all"
  extension-element-prefixes="datacite">

  <xsl:param name="MCR.Users.Superuser.UserName" />
  <xsl:param name="MIR.registerDOI" select="''" />
  <xsl:param name="MIR.registerURN" select="'true'" />
  <xsl:param name="MIR.METSEditor.enable" select="'false'" />
  <xsl:param name="template" select="'fixme'" />

  <xsl:param name="MCR.Packaging.Packer.ImageWare.FlagType" />
  <xsl:param name="MIR.ImageWare.Enabled" />
  <xsl:param name="MIR.Workflow.Menu" select="'false'" />
  <xsl:param name="MCR.Module-iview2.SupportedContentTypes"/>
  <xsl:param name="MIR.Strategy.EditPIRoles" />
  <xsl:param name="MIR.Thumbnail.IIIF.Resolution" select="'!300,300'" />

  <xsl:include href="resource:xslt/workflow-util.xsl" />
  <xsl:include href="resource:xslt/mir-mods-utils.xsl" />
  <xsl:include href="resource:xslt/mir-utils.xsl" />

  <!-- do nothing for display parent -->
  <xsl:template match="/mycoreobject" mode="parent" priority="1">
  </xsl:template>

  <xsl:template mode="printDerivatesThumb" match="/mycoreobject[contains(@ID,'_mods_')]" priority="1">
    <xsl:param name="staticURL" />
    <xsl:param name="layout" />
    <xsl:param name="xmltempl" />
    <xsl:param name="modsType" select="'report'" />
    <xsl:variable name="suffix">
      <xsl:if test="string-length($layout)&gt;0">
        <xsl:value-of select="concat('&amp;layout=',$layout)" />
      </xsl:if>
    </xsl:variable>
    <xsl:if test="./structure/derobjects">

      <div class="hit_symbol">
        <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/big/icon_{$modsType}.png" alt="{$modsType}" title="{$modsType}" />
        <xsl:variable name="embargo" select="metadata/def.modsContainer/modsContainer/mods:mods/mods:accessCondition[@type='embargo']" />
        <xsl:choose>
<!-- TODO:          <xsl:when test="mcracl:is-current-user-in-role('guest') and count($embargo) &gt; 0 and mcrxml:compare(string($embargo),dt:date-time()) &gt; 0">-->
          <xsl:when test="mcracl:is-current-user-in-role('guest') and count($embargo) &gt; 0 and false()">
            <!-- embargo is active for guest user -->
            <xsl:value-of select="mcri18n:translate-with-params('component.mods.metaData.dictionary.accessCondition.embargo.available',$embargo)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="./structure/derobjects/derobject">
              <xsl:variable name="deriv" select="@xlink:href" />
              <xsl:variable name="derivlink" select="concat('mcrobject:',$deriv)" />
              <xsl:variable name="derivate" select="document($derivlink)" />
              <xsl:variable name="fileType" select="document(concat('ifs:/',@xlink:href,'/'))/mcr_directory/children/child/contentType" />

              <xsl:variable name="derivid" select="$derivate/mycorederivate/@ID" />
              <xsl:variable name="derivlabel" select="$derivate/mycorederivate/@label" />
              <xsl:variable name="derivmain" select="$derivate/mycorederivate/derivate/internals/internal/@maindoc" />
              <xsl:variable name="derivbase" select="concat($ServletsBaseURL,'MCRFileNodeServlet/',$derivid,'/')" />
              <xsl:variable name="derivifs" select="concat($derivbase,$derivmain)" />
              <xsl:variable name="derivdir" select="$derivbase" />

              <div class="hit_links">
                <a href="{$derivifs}">
                  <xsl:choose>
                    <xsl:when
                      test="$fileType='pdf' or $fileType='msexcel' or $fileType='xlsx' or $fileType='msword97' or $fileType='docx' or $fileType='html' or $fileType='rtf' or $fileType='txt' or $fileType='xml'"
                    >
                      <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/download_{$fileType}.png" alt="{$derivmain}" title="{$derivmain}" />
                    </xsl:when>
                    <xsl:otherwise>
                      <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/download_default.png" alt="{$derivmain}" title="{$derivmain}" />
                    </xsl:otherwise>
                  </xsl:choose>
                </a>
                <a href="{$derivdir}">
                <!-- xsl:value-of select="i18n:translate('buttons.details')" / -->
                  <img src="{$WebApplicationBaseURL}templates/master/{$template}/IMAGES/icons_liste/download_details.png" alt="Details" title="Details"
                    style="padding-bottom:2px;" />
                </a>
              </div>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:accessCondition" mode="rights_reserved" priority="1">
    <img>
      <xsl:attribute name="src">
        <xsl:value-of select="concat($WebApplicationBaseURL, 'templates/master/', $template , '/IMAGES/copyright.png')" />
      </xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:value-of select="mcri18n:translate('component.mods.metaData.dictionary.rightsReserved')" />
      </xsl:attribute>
    </img>
  </xsl:template>

  <xsl:template match="children" mode="printChildren" priority="1">
    <xsl:param name="label" select="'enthält'" />

    <!-- the for-each would iterate over <id> with root not beeing /mycoreobject so we save the current node in variable context to access
      needed nodes -->
    <xsl:variable name="context" select="/mycoreobject" />

    <xsl:variable name="children" select="$context/structure/children/child[string(document(concat('org.mycore.common.xml.MCRXMLFunctions:isInCategory',@xlink:href,':','state:published')))='true']" />
    <xsl:variable name="maxElements" select="20" />
    <xsl:variable name="positionMin">
      <xsl:choose>
        <xsl:when test="count($children) &gt; $maxElements">
          <xsl:value-of select="count($children) - $maxElements + 1" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="0" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <tr>
      <td valign="top" class="metaname">
        <xsl:value-of select="concat($label,':')" />
      </td>
      <td class="metavalue">
        <xsl:if test="$positionMin != 0">
          <p>
            <a href="{$ServletsBaseURL}MCRSearchServlet?parent={$context/@ID}">
              <xsl:value-of select="mcri18n:translate('component.mods.metaData.displayAll')" />
            </a>
          </p>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="count($children) &gt; 1">
            <!-- display recent $maxElements only -->
            <ul class="document_children">
              <xsl:for-each select="$children[position() &gt;= $positionMin]">
                <li>
                  <xsl:call-template name="objectLink">
                    <xsl:with-param name="obj_id" select="@xlink:href" />
                  </xsl:call-template>
                </li>
              </xsl:for-each>
            </ul>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="objectLink">
              <xsl:with-param name="obj_id" select="$children/@xlink:href" />
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </td>
    </tr>
  </xsl:template>


  <xsl:template match="/mycoreobject" mode="breadCrumb" priority="1">

    <ul class="breadcrumb">
      <li class="first">
        <a href="{$WebApplicationBaseURL}content/main/classifications/mir_genres.xml">
          <xsl:value-of select="mcri18n:translate('editor.search.mir.genre')" />
        </a>
      </li>
      <xsl:if test="./structure/parents">
        <xsl:variable name="parent_genre">
          <xsl:apply-templates mode="mods-type" select="document(concat('mcrobject:',./structure/parents/parent/@xlink:href))/mycoreobject" />
        </xsl:variable>
        <li>
          <xsl:value-of select="mcri18n:translate(concat('component.mods.metaData.dictionary.', $parent_genre))" />
          <xsl:text>: </xsl:text>
          <xsl:apply-templates select="./structure/parents">
            <xsl:with-param name="obj_type" select="'this'" />
          </xsl:apply-templates>
          <xsl:apply-templates select="./structure/parents">
            <xsl:with-param name="obj_type" select="'before'" />
          </xsl:apply-templates>
          <xsl:apply-templates select="./structure/parents">
            <xsl:with-param name="obj_type" select="'after'" />
          </xsl:apply-templates>
        </li>
      </xsl:if>

      <xsl:variable name="internal_genre">
        <xsl:apply-templates mode="mods-type" select="." />
      </xsl:variable>
      <li>
        <xsl:value-of select="mcri18n:translate(concat('component.mods.metaData.dictionary.', $internal_genre))" />
      </li>
      <xsl:if test="./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre[@type='kindof']">
        <li>
          <xsl:apply-templates select="./metadata/def.modsContainer/modsContainer/mods:mods/mods:genre[@type='kindof']" mode="printModsClassInfo" />
        </li>
      </xsl:if>
    </ul>

  </xsl:template>

  <xsl:template match="/mycoreobject[contains(@ID,'_mods_')]" mode="objectActions" priority="2">
    <xsl:param name="id" select="./@ID" />
    <xsl:param name="accessedit" select="key('rights', $id)/@write" />
    <xsl:param name="accessdelete" select="key('rights', $id)/@delete" />
    <xsl:param name="hasURN" select="'false'" />
    <xsl:param name="displayAddDerivate" select="'true'" />
    <xsl:param name="layout" select="'$'" />
    <xsl:param name="mods-type" select="'report'" />
    <xsl:variable name="layoutparam">
      <xsl:if test="$layout != '$'">
        <xsl:value-of select="concat('&amp;layout=',$layout)" />
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="editURL">
      <xsl:call-template name="mods.getObjectEditURL">
        <xsl:with-param name="id" select="$id" />
        <xsl:with-param name="layout" select="$layout" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="adminEditURL">
      <xsl:value-of select="mcractionmapping:get-url-for-id('update-admin',$id,true())" />
    </xsl:variable>
    <xsl:variable name="copyURL">
      <xsl:value-of select="mcractionmapping:get-url-for-id('create-copy',$id,true())" />
    </xsl:variable>
    <xsl:variable name="basketType" select="'objects'" />
    <div class="btn-group d-flex">
      <xsl:choose>
        <xsl:when test="document(concat('callJava:org.mycore.frontend.basket.MCRBasketManager:contains:',$basketType,':',/mycoreobject/@ID))">
          <a class="btn btn-primary btn-sm w-100"
             href="{$ServletsBaseURL}MCRBasketServlet?type={$basketType}&amp;action=remove&amp;redirect={encode-for-uri($RequestURL)}&amp;id={/mycoreobject/@ID}">
            <i class="fas fa-minus">
              <xsl:value-of select="' '" />
            </i>
            <xsl:value-of select="concat(' ',mcri18n:translate('basket.remove'))" />
          </a>
        </xsl:when>
        <xsl:otherwise>
          <a class="btn btn-primary btn-sm w-100"
             href="{$ServletsBaseURL}MCRBasketServlet?type={$basketType}&amp;action=add&amp;redirect={encode-for-uri($RequestURL)}&amp;id={/mycoreobject/@ID}&amp;uri=mcrobject:{/mycoreobject/@ID}"
          >
            <i class="fas fa-plus">
              <xsl:value-of select="' '" />
            </i>
            <xsl:value-of select="concat(' ',mcri18n:translate('basket.add'))" />
          </a>
        </xsl:otherwise>
      </xsl:choose>
      <div class="btn-group w-100">
        <a href="#" class="btn btn-secondary btn-sm dropdown-toggle" data-bs-toggle="dropdown" data-display="static" >
          <i class="fas fa-cog">
            <xsl:value-of select="' '" />
          </i>
          <xsl:value-of select="concat(' ',mcri18n:translate('mir.actions'))" />
          <span class="caret"></span>
        </a>

        <ul class="dropdown-menu dropdown-menu-end">
          <xsl:variable name="type" select="substring-before(substring-after($id,'_'),'_')" />
          <xsl:choose>
            <xsl:when test="not($accessedit) and mcracl:is-current-user-in-role('guest')">
              <li class="mir-action-item">
                <a href="{concat($ServletsBaseURL, 'MCRLoginServlet?url=', encode-for-uri(string($RequestURL)))}" class="dropdown-item">
                  <xsl:value-of select="mcri18n:translate('mir.actions.noaccess')" />
                </a>
              </li>
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="not($accessedit or $accessdelete)">
                <li class="mir-action-item">
                  <a href="{concat($ServletsBaseURL, 'MCRLoginServlet?url=', encode-for-uri(string($RequestURL)))}" class="dropdown-item">
                    <xsl:value-of select="mcri18n:translate('mir.actions.norights')" />
                  </a>
                </li>

              </xsl:if>
              <xsl:if test="$accessedit">
                <xsl:choose>
                  <xsl:when test="string-length($editURL) &gt; 0">
                    <li class="mir-action-item mir-action-item-edit-object">
                      <a href="{$editURL}" class="dropdown-item">
                        <xsl:value-of select="mcri18n:translate('object.editObject')" />
                      </a>
                    </li>
                    <xsl:if test="string-length($adminEditURL) &gt; 0">
                      <li class="mir-action-item mir-action-item-edit-object-admin">
                        <a href="{$adminEditURL}&amp;id={$id}" class="dropdown-item">
                          <xsl:value-of select="mcri18n:translate('mir.admineditor')" />
                        </a>
                      </li>
                    </xsl:if>
                    <xsl:if test="normalize-space($MIR.Workflow.Menu)='true'">
                      <xsl:call-template name="listStatusChangeOptions">
                        <xsl:with-param name="class" select="'dropdown-item'"/>
                      </xsl:call-template>
                    </xsl:if>
                    <!-- li> does not work atm
                      <a href="{$WebApplicationBaseURL}editor/change_genre.xed?id={$id}">
                        <xsl:value-of select="i18n:translate('object.editGenre')" />
                      </a>
                    </li -->
                  </xsl:when>
                  <xsl:otherwise>
                    <li class="dropdown-item">
                      <xsl:value-of select="mcri18n:translate('object.locked')" />
                    </li>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:variable name="isAllowedToEditPI">
                  <xsl:for-each select="tokenize($MIR.Strategy.EditPIRoles,',')">
                    <xsl:if test="mcracl:is-current-user-in-role(.)">
                      <xsl:text>true</xsl:text>
                    </xsl:if>
                  </xsl:for-each>
                </xsl:variable>
                <xsl:if test="$displayAddDerivate='true' and key('rights', @ID)/@write and mcracl:check-permission('', 'create-derivate') and (not(mcrpi:has-managed-pi($id)) or contains($isAllowedToEditPI, 'true'))">
                  <li class="mir-action-item mir-action-item-add-derivate">
                    <a onclick="javascript: $('.drop-to-object-optional').toggle();" class="dropdown-item">
                      <xsl:value-of select="mcri18n:translate('mir.upload.addDerivate')" />
                    </a>
                  </li>
                </xsl:if>
                <!-- Register DOI -->
                <xsl:variable name="piServiceInformation" select="mcrpi:get-pi-service-information($id)" />
                <xsl:for-each select="$piServiceInformation">
                  <xsl:sort select="@type" />
                  <xsl:sort select="@id" />
                  <xsl:if test="@permission='true'">
                    <li class="mir-action-item mir-action-item-register-pi mir-action-item-register-{@type}">
                    <!-- data-type is just used for translation -->
                      <a href="#" data-type="{@type}"
                         data-mycoreID="{$id}"
                         data-baseURL="{$WebApplicationBaseURL}">
                        <xsl:attribute name="class">
                          <xsl:text>dropdown-item</xsl:text>
                          <xsl:if test="@inscribed='true'">
                            <xsl:text> disabled</xsl:text>
                          </xsl:if>
                        </xsl:attribute>
                        <xsl:if test="@inscribed='false'">
                          <xsl:attribute name="data-register-pi" >
                            <xsl:value-of select="@id" />
                          </xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="mcri18n:translate(concat('component.pi.register.',@id))" />
                    </a>
                    </li>
                  </xsl:if>
                </xsl:for-each>
                <!-- Packing with ImageWare Packer -->
                <xsl:if test="string(document(concat('callJava:org.mycore.mir.imageware.MIRImageWarePacker:displayPackerButton:',$id,':ImageWare')))='true'">
                  <li class="mir-action-item mir-action-item-display-packer-button">
                    <a
                      class="dropdown-item"
                      href="{$ServletsBaseURL}MCRPackerServlet?packer=ImageWare&amp;objectId={/mycoreobject/@ID}&amp;redirect={encode-for-uri(concat($WebApplicationBaseURL,'receive/',/mycoreobject/@ID,'?XSL.Status.Message=mir.iwstatus.success&amp;XSL.Status.Style=success'))}">
                      <xsl:value-of select="mcri18n:translate('object.createImagewareZipPackage')" />
                    </a>
                  </li>
                </xsl:if>
              </xsl:if>
              <xsl:if test="mcracl:check-permission('','create-mods')">
                <xsl:if test="string-length($copyURL) &gt; 0">
                  <li class="mir-action-item mir-action-item-copy-object">
                    <a href="{$copyURL}?copyofid={$id}" class="dropdown-item">
                      <xsl:value-of select="mcri18n:translate('object.copyObject')" />
                    </a>
                  </li>
                </xsl:if>
                <xsl:if test="string-length($copyURL) &gt; 0">
                  <li class="mir-action-item mir-action-item-copy-object-new-version">
                    <a href="{$copyURL}?oldVersion={$id}" class="dropdown-item">
                      <xsl:value-of select="mcri18n:translate('object.newVersion')" />
                    </a>
                  </li>
                </xsl:if>
              </xsl:if>
              <xsl:if test="$CurrentUser=$MCR.Users.Superuser.UserName or $accessdelete">
                <li class="mir-action-item mir-action-item-delete-object">
                  <xsl:choose>
                    <xsl:when test="/mycoreobject/structure/children/child">
                      <xsl:attribute name="class">
                        <xsl:value-of select="'disabled'" />
                      </xsl:attribute>
                      <a href="#" title="{mcri18n:translate('object.hasChildren')}" class="dropdown-item">
                        <xsl:value-of select="mcri18n:translate('object.delObject')" />
                      </a>
                    </xsl:when>
                    <xsl:otherwise>
                      <a href="{$ServletsBaseURL}object/delete?id={$id}" class="confirm_deletion dropdown-item" data-text="{mcri18n:translate('mir.confirm.text')}">
                        <xsl:value-of select="mcri18n:translate('object.delObject')" />
                      </a>
                    </xsl:otherwise>
                  </xsl:choose>
                </li>
              </xsl:if>

              <xsl:variable name="edit-all-mods-url" select="mcractionmapping:get-url-for-id('update-xml', $id, true())" />
              <xsl:if test="string-length($edit-all-mods-url) &gt; 0">
                <li>
                  <a href="{$edit-all-mods-url}{$id}" class="dropdown-item">
                    <xsl:value-of select="mcri18n:translate('component.mods.object.editAllModsXML')" />
                  </a>
                </li>
              </xsl:if>
              <xsl:variable name="genreHosts" select="document('classification:metadata:-1:children:mir_genres')" />
              <xsl:variable name="child-layout">
                <xsl:for-each select="$genreHosts//category[contains(label[@xml:lang='x-hosts']/@text, $mods-type)]">
                  <xsl:value-of select="@ID" />
                  <xsl:text>|</xsl:text>
                </xsl:for-each>
              </xsl:variable>
              <!-- xsl:message>
                mods-type:
                <xsl:value-of select="$mods-type" />
                child-layout:
                <xsl:value-of select="$child-layout" />
                accessedit:
                <xsl:value-of select="$accessedit" />
              </xsl:message -->
              <!-- actionmapping.xml must be available for this functionality -->
              <xsl:if test="string-length($child-layout) &gt; 0 and $accessedit and doc-available('resource:actionmappings.xml')">

                <xsl:variable name="url">
                  <xsl:value-of select="mcractionmapping:get-url-for-id('create-child',$id,true())"  />
                </xsl:variable>
                <xsl:variable name="genres" select="tokenize($child-layout, '\|')[normalize-space()]"/>

                <xsl:choose>
                  <xsl:when test="not(contains($url, 'editor-dynamic.xed')) and $mods-type != 'series'">
                    <xsl:for-each select="$genres">
                      <li>
                        <a href="{$url}?relatedItemId={$id}&amp;relatedItemType=host&amp;genre={.}" class="dropdown-item">
                          <xsl:value-of select="mcrclassification:current-label-text(mcrclassification:category('mir_genres',.))" />
                        </a>
                      </li>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:when test="not(contains($url, 'editor-dynamic.xed')) and $mods-type = 'series'">
                    <xsl:for-each select="$genres">
                      <li>
                        <a href="{$url}?relatedItemId={$id}&amp;relatedItemType=series&amp;genre={.}" class="dropdown-item">
                          <xsl:value-of select="mcrclassification:current-label-text(mcrclassification:category('mir_genres',.))" />
                        </a>
                      </li>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:when test="contains($url, 'editor-dynamic.xed') and $mods-type = 'lecture'">
                    <xsl:for-each select="$genres">
                      <li>
                        <a href="{$url}?relatedItemId={$id}&amp;relatedItemType=series&amp;genre={.}&amp;host={$mods-type}" class="dropdown-item">
                          <xsl:value-of select="mcrclassification:current-label-text(mcrclassification:category('mir_genres',.))" />
                        </a>
                      </li>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:for-each select="$genres">
                      <li>
                        <a href="{$url}?relatedItemId={$id}&amp;relatedItemType=host&amp;genre={.}" class="dropdown-item">
                          <xsl:value-of select="mcrclassification:current-label-text(mcrclassification:category('mir_genres',.))" />
                        </a>
                      </li>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:if>
              <xsl:if test="miraccesskeyutil:is-access-key-allowed($id)">
                <xsl:call-template name="print-manage-access-keys-menu-item">
                  <xsl:with-param name="reference" select="$id" />
                </xsl:call-template>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="not($accessedit or $accessdelete)">
            <xsl:if test="miraccesskeyutil:can-current-user-redeem-access-key($id)">
              <xsl:call-template name="print-set-access-key-menu-item">
                <xsl:with-param name="reference" select="$id" />
              </xsl:call-template>
            </xsl:if>
          </xsl:if>
        </ul>
      </div>
    </div>
    <div class="modal fade" id="modal-pi" tabindex="-1" role="dialog" data-backdrop="static">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title" data-i18n="component.pi.register."></h4>
          </div>
          <div class="modal-body">
            <div class="row">
              <div class="col-md-2">
                <i class="fas fa-question-circle"></i>
              </div>
              <div class="col-md-10" data-i18n="component.pi.register.modal.text."></div>
            </div>
          </div>
          <div class="modal-footer">
            <button type="button" class="btn btn-secondary modal-pi-cancel" data-bs-dismiss="modal">
              <xsl:value-of select="mcri18n:translate('component.pi.register.modal.abort')" />
            </button>
            <button type="button" class="btn btn-danger" id="modal-pi-add"
                    data-i18n="component.pi.register.">
            </button>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="derobject" mode="derivateActions">
    <xsl:param name="deriv" />
    <xsl:param name="parentObjID" />

    <xsl:if test="key('rights', $deriv)/@read">
      <xsl:variable select="concat('mcrobject:',$deriv)" name="derivlink" />
      <xsl:variable select="document($derivlink)" name="derivate" />

      <div class="dropdown float-end options">
        <div class="btn-group">
          <a href="#" class="btn btn-secondary dropdown-toggle" data-bs-toggle="dropdown">
            <i class="fas fa-cog"></i>
            <xsl:value-of select="concat(' ',mcri18n:translate('mir.actions'))" />
          </a>
          <ul class="dropdown-menu dropdown-menu-end">
            <xsl:if test="key('rights', $deriv)/@write">
              <li>
                <a href="{$WebApplicationBaseURL}editor/editor-derivate.xed?derivateid={$deriv}&amp;cancelUrl={encode-for-uri($RequestURL)}" class="option dropdown-item">
                  <xsl:value-of select="mcri18n:translate('component.mods.metaData.options.updateDerivateName')" />
                </a>
              </li>
            </xsl:if>
            <xsl:if test="key('rights', $deriv)/@write and string(document(concat('callJava:org.mycore.iview2.services.MCRIView2Tools:getSupportedMainFile:',$deriv))) and normalize-space($MIR.METSEditor.enable)='true'">
              <li>
                <a href="{$WebApplicationBaseURL}rsc/mets/editor/start/{$deriv}" class="option startmets dropdown-item">
                  <xsl:value-of select="mcri18n:translate('component.mods.metaData.options.startmets')" />
                </a>
              </li>
            </xsl:if>
            <xsl:if test="key('rights', $deriv)/@read">
              <li>
                <!-- Link to toggle to show/hide md5 sum -->
                <a href="#" class="option dropdown-item toggleMD5Link">
                  <xsl:value-of select="mcri18n:translate('component.mods.metaData.options.MD5.show')" />
                </a>
              </li>
              <li>
                <a href="{$ServletsBaseURL}MCRZipServlet/{$deriv}" class="option downloadzip dropdown-item">
                  <xsl:value-of select="mcri18n:translate('component.mods.metaData.options.zip')" />
                </a>
              </li>
            </xsl:if>
            <!--<xsl:if test="key('rights', $deriv)/@write">
              <li>
                <xsl:if test="not(key('rights', $deriv)/@delete)">
                  <xsl:attribute name="class">last</xsl:attribute>
                </xsl:if>
                <xsl:choose>
                    <a href="{$ServletsBaseURL}derivate/update?objectid={../../../@ID}&amp;id={$deriv}" class="option">
                      <xsl:value-of select="i18n:translate('component.mods.metaData.options.addFile')" />
                    </a>
                  <xsl:otherwise>
                    <xsl:value-of select="i18n:translate('component.mods.metaData.options.derivateLocked')" />
                  </xsl:otherwise>
                </xsl:choose>
              </li>
            </xsl:if>-->
            <xsl:if test="key('rights', $deriv)/@delete">
              <li class="last">
                <a href="{$ServletsBaseURL}derivate/delete?id={$deriv}" class="confirm_deletion option dropdown-item" data-text="{mcri18n:translate('mir.confirm.derivate.text')}">
                  <xsl:value-of select="mcri18n:translate('component.mods.metaData.options.delDerivate')" />
                </a>
              </li>
            </xsl:if>
            <xsl:if test="miraccesskeyutil:is-access-key-allowed($deriv)">
              <xsl:call-template name="print-manage-access-keys-menu-item">
                <xsl:with-param name="reference" select="$deriv"/>
              </xsl:call-template>
            </xsl:if>
          </ul>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="print-manage-access-keys-menu-item">
    <xsl:param name="reference" as="xs:string" />

    <xsl:variable name="available-permissions" select="
      miraccesskeyutil:get-manageable-permissions($reference, ('read', 'writedb'))
    " />
    <xsl:if test="exists($available-permissions)">
      <li class="mir-action-item mir-action-item-manage-access-key">
        <xsl:variable name="permissions" select="string-join($available-permissions, ',')" />
        <a
          role="menuitem"
          tabindex="-1"
          class="dropdown-item"
          href="{$WebApplicationBaseURL}access-key-manager/{$reference}?availablePermissions={$permissions}"
        >
          <xsl:value-of select="mcri18n:translate('mir.accesskey.manage')" />
        </a>
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template name="print-set-access-key-menu-item">
    <xsl:param name="reference" as="xs:string" />

    <li class="mir-action-item mir-action-item-activate-access-key">
      <a
        role="menuitem"
        tabindex="-1"
        href="{$WebApplicationBaseURL}accesskey/set.xed?objId={$reference}&amp;url={encode-for-uri(string($RequestURL))}"
        class="dropdown-item">
        <xsl:value-of select="mcri18n:translate('mir.accesskey.setOnUser')" />
      </a>
    </li>
  </xsl:template>

  <xsl:template match="/mycoreobject[contains(@ID,'_mods_')]" mode="basketContent" priority="1">
    <xsl:variable name="objID" select="@ID" />
    <xsl:variable name="mods-type">
      <xsl:apply-templates select="." mode="mods-type" />
    </xsl:variable>

    <xsl:for-each select="./metadata/def.modsContainer/modsContainer/mods:mods">

<!-- document preview -->
      <div class="hit_download_box">
        <xsl:choose>
        <!-- we got a derivate -->
        <xsl:when test="../../../../structure/derobjects">
          <xsl:variable name="identifier" select="../../../../@ID" />
          <xsl:variable name="derivid" select="../../../../structure/derobjects/derobject[1]/@xlink:href" />
          <xsl:variable name="derivate" select="document(concat('mcrobject:',$derivid))" />
          <xsl:variable name="maindoc" select="$derivate/mycorederivate/derivate/internals/internal/@maindoc" />
          <xsl:variable name="contentType" select="document(concat('ifs:/',$derivid))/mcr_directory/children/child[name=$maindoc]/contentType" />

          <xsl:choose>
            <xsl:when test="contains($MCR.Module-iview2.SupportedContentTypes, $contentType) or $contentType ='application/pdf'">
              <div class="hit_icon">
                <xsl:choose>
                  <xsl:when test="not(mcracl:is-current-user-in-role('guest'))">
                    <xsl:attribute name="data-iiif-jwt">
                      <xsl:value-of select="concat($WebApplicationBaseURL, 'api/iiif/image/v2/thumbnail/', $objID,'/full/', $MIR.Thumbnail.IIIF.Resolution, '/0/default.jpg')"/>
                    </xsl:attribute>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:attribute name="style">
                      <xsl:variable name="apos">'</xsl:variable>
                      <xsl:value-of
                              select="concat('background-image: url(', $apos, $WebApplicationBaseURL, 'api/iiif/image/v2/thumbnail/', $objID, '/full/', $MIR.Thumbnail.IIIF.Resolution, '/0/default.jpg',$apos,')')"/>
                    </xsl:attribute>
                  </xsl:otherwise>
                </xsl:choose>
              </div>
            </xsl:when>
            <xsl:otherwise>
              <div class="hit_icon"
                   style="background-image: url('{$WebApplicationBaseURL}images/icons/icon_common.png');"/>
              <!-- if not, then the content type decides a icon -->
              <xsl:variable name="iconLink">
                <xsl:call-template name="iconLink">
                  <xsl:with-param name="baseURL" select="$WebApplicationBaseURL"/>
                  <xsl:with-param name="mimeType" select="$contentType"/>
                </xsl:call-template>
              </xsl:variable>
              <img class="hit_icon_overlay" src="{$iconLink}"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
          <!-- no derivate -->
          <xsl:otherwise>
            <!-- show default icon -->
            <img alt="" class="hit_icon" src="{$WebApplicationBaseURL}images/icons/icon_common_disabled.png" />
          </xsl:otherwise>
        </xsl:choose>
      </div>

<!-- hit type -->
      <div class="hit_tnd_container">
        <div class="hit_tnd_content mir-badge-container">
          <xsl:apply-templates select="document(concat('solr:q=id%3A', $objID))/response/result/doc" mode="badge"/>
        </div>
      </div>

      <!-- Title, Link to presentation -->
      <h3 class="hit_title">
        <xsl:call-template name="objectLink">
          <xsl:with-param name="obj_id" select="$objID" />
        </xsl:call-template>
      </h3>

<!-- hit author -->
      <div class="hit_author">
        <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='aut']">
          <xsl:if test="position()!=1">
            <xsl:value-of select="'/ '" />
          </xsl:if>
          <xsl:apply-templates select="." mode="mirNameLink" />
        </xsl:for-each>
      </div>

<!-- hit parent -->
      <xsl:if test="../../../../structure/parents/parent/@xlink:href">
        <div class="hit_source">
          <span class="label_parent">
            <xsl:value-of select="'aus: '" />
          </span>
          <xsl:call-template name="objectLink">
            <xsl:with-param name="obj_id" select="../../../../structure/parents/parent/@xlink:href" />
          </xsl:call-template>
        </div>
      </xsl:if>

<!-- hit abstract -->
      <div class="hit_abstract">
        <xsl:if test="mods:abstract[not(@altFormat)]">
          <xsl:choose>
            <xsl:when test="mods:abstract[not(@altFormat)][@xml:lang=$CurrentLang]">
              <xsl:value-of select="mcrstringutils:shorten(mods:abstract[not(@altFormat)][@xml:lang=$CurrentLang][1],300)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="mcrstringutils:shorten(mods:abstract[not(@altFormat)][1],300)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </div>

<!-- hit publisher -->
      <xsl:if test="//mods:originInfo[not(@eventType) or @eventType='publication']/mods:publisher">
        <div class="hit_pub_name">
          <span class="label_publisher">
            <xsl:value-of select="concat(mcri18n:translate('component.mods.metaData.dictionary.published'),': ')" />
          </span>
          <xsl:value-of select="//mods:originInfo/mods:publisher" />
        </div>
      </xsl:if>

      <xsl:if test="//mods:originInfo[@eventType='creation']/mods:publisher">
        <div class="hit_pub_name">
          <span class="label_publisher">
            <xsl:value-of select="concat(mcri18n:translate('component.mods.metaData.dictionary.publisher.creation'),': ')" />
          </span>
          <xsl:value-of select="//mods:originInfo[@eventType='creation']/mods:publisher" />
        </div>
      </xsl:if>
    </xsl:for-each>

  </xsl:template>

  <!-- TODO validation award title and number -->
  <xsl:template match="mods:extension[@type='datacite-funding']" mode="funding">
    <xsl:for-each select="datacite:fundingReferences/datacite:fundingReference">
      <tr>
        <td valign="top" class="metaname">
          <xsl:value-of select="mcri18n:translate('mir.project')"/>
        </td>
        <td class="metavalue">
          <xsl:value-of select="datacite:funderName"/>
          <xsl:if test="datacite:awardTitle or datacite:awardNumber">
            <br/>
            <xsl:if test="datacite:awardTitle">
              <i>
                <xsl:value-of select="datacite:awardTitle"/>
              </i>
            </xsl:if>
            <xsl:if test="datacite:awardNumber">
              <xsl:text> [</xsl:text>
              <xsl:choose>
                <xsl:when test="datacite:awardNumber/@awardURI">
                  <a target="_blank" href="{datacite:awardNumber/@awardURI}">
                    <xsl:value-of select="datacite:awardNumber"/>
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="datacite:awardNumber"/>
                </xsl:otherwise>
              </xsl:choose>
              <xsl:text>]</xsl:text>
            </xsl:if>
          </xsl:if>
        </td>
      </tr>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
